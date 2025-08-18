import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/theme.dart';
import 'package:freeflow/utils.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:freeflow/widgets/error.dart';
import 'package:freeflow/widgets/profile_name.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/domain_layer/usecases/lnurl/lnurl.dart';
import 'package:ndk/ndk.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ZapWidget extends StatefulWidget {
  final String pubkey;
  final Nip01Event? target;
  final List<Nip01Event>? otherTargets;
  final List<List<String>>? zapTags;
  final void Function(String preimage)? onPaid;

  const ZapWidget({
    super.key,
    required this.pubkey,
    this.target,
    this.zapTags,
    this.otherTargets,
    this.onPaid,
  });

  @override
  State<StatefulWidget> createState() => _ZapWidget();
}

class _ZapWidget extends State<ZapWidget> {
  final TextEditingController _comment = TextEditingController();
  final TextEditingController _customAmount = TextEditingController();
  final FocusNode _customAmountFocus = FocusNode();
  bool _loading = false;
  String? _error;
  String? _pr;
  int? _amount;
  final _zapAmounts = [
    50,
    100,
    200,
    500,
    1000,
    5000,
    10000,
    50000,
    100000,
    1000000,
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.maxFinite,
      child: Column(
        spacing: 10,
        children: [
          ProfileLoaderWidget(widget.pubkey, (context, state) {
            final profile = state.data ?? Metadata(pubKey: widget.pubkey);
            return Text(
              "Zap ${ProfileNameWidget.nameFromProfile(profile)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            );
          }),
          if (_pr == null && !_loading) ..._inputs(),
          if (_pr != null) ..._invoice(context),
          if (_loading) CircularProgressIndicator(),
        ],
      ),
    );
  }

  List<Widget> _inputs() {
    return [
      GridView.builder(
        shrinkWrap: true,
        itemCount: _zapAmounts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 1.9,
        ),
        itemBuilder: (ctx, idx) => _zapAmount(_zapAmounts[idx]),
      ),
      Row(
        spacing: 8,
        children: [
          Expanded(
            child: TextFormField(
              controller: _customAmount,
              focusNode: _customAmountFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Custom Amount"),
            ),
          ),
          BasicButton.text(
            "Confirm",
            onTap: (context) {
              final newAmount = int.tryParse(_customAmount.text);
              if (newAmount != null) {
                setState(() {
                  _error = null;
                  _amount = newAmount;
                  _customAmountFocus.unfocus();
                });
              } else {
                setState(() {
                  _error = "Invalid custom amount";
                  _amount = null;
                });
              }
            },
          ),
        ],
      ),
      TextFormField(
        controller: _comment,
        decoration: InputDecoration(labelText: "Comment"),
      ),
      BasicButton.text(
        _amount != null ? "Zap ${formatSats(_amount!)} sats" : "Zap",
        disabled: _amount == null,
        decoration: BoxDecoration(
            color: NEUTRAL_800, borderRadius: BorderRadius.circular(8)),
        onTap: (context) async {
          try {
            setState(() {
              _error = null;
              _loading = true;
            });
            await _loadZap(context);
          } catch (e) {
            setState(() {
              _error = e.toString();
            });
          } finally {
            setState(() {
              _loading = false;
            });
          }
        },
      ),
      if (_error != null) ErrorText(_error!)
    ];
  }

  List<Widget> _invoice(BuildContext context) {
    final prLink = "lightning:${_pr!}";

    return [
      QrImageView(
        data: _pr!,
        size: 256,
        backgroundColor: Colors.transparent,
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
        eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
      ),
      GestureDetector(
        onTap: () async {
          await FlutterClipboard.copy(_pr!);
          if (!Platform.isAndroid && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Copied to clipboard!")));
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: NEUTRAL_800),
          child: Row(
            spacing: 4,
            children: [
              Icon(
                Icons.copy,
                size: 16,
                color: Colors.white,
              ),
              Expanded(
                  child: Text(
                _pr!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                ),
              )),
            ],
          ),
        ),
      ),
      BasicButton.text(
        "Open Wallet",
        onTap: (_) async {
          try {
            await launchUrlString(prLink);
          } catch (e) {
            if (e is PlatformException) {
              if (e.code == "ACTIVITY_NOT_FOUND") {
                setState(() {
                  _error = "No wallet found";
                });
                return;
              }
            }
            setState(() {
              _error = e is String ? e : e.toString();
            });
          }
        },
      ),
      if (LOGIN.value?.wallet == null)
        BasicButton.text(
          "Connect Wallet",
          onTap: (context) async {
            context.push("/settings/wallet");
          },
        ),
      if (_error != null) ErrorText(_error!),
    ];
  }

  Future<ZapRequest?> _makeZap() async {
    final signer = ndk.accounts.getLoggedAccount()?.signer;
    if (signer == null) return null;

    var relays = DEFAULT_RELAYS;
    // if target event has relays tag, use that for zap
    if (widget.target?.tags.any((t) => t[0] == "relays") ?? false) {
      relays = widget.target!.tags.firstWhere((t) => t[0] == "relays").slice(1);
    }
    final amount = _amount! * 1000;

    var tags = [
      ["relays", ...relays],
      ["amount", amount.toString()],
      ["p", widget.pubkey],
    ];

    // tag targets for zap request
    for (final t in [
      ...(widget.target != null ? [widget.target!] : []),
      ...(widget.otherTargets != null ? widget.otherTargets! : []),
    ]) {
      if (t.kind >= 30_000 && t.kind < 40_000) {
        tags.add(["a", "${t.kind}:${t.pubKey}:${t.getDtag()!}"]);
      } else {
        tags.add(["e", t.id]);
      }
    }
    if (widget.zapTags != null) {
      tags.addAll(widget.zapTags!);
    }
    var event = ZapRequest(
      pubKey: signer.getPublicKey(),
      tags: tags,
      content: _comment.text,
    );
    await signer.sign(event);
    return event;
  }

  Future<void> _loadZap(BuildContext context) async {
    final profile = await ndk.metadata.loadMetadata(widget.pubkey);
    if (profile?.lud16 == null) {
      throw "No lightning address found!";
    }

    final zapRequest = await _makeZap();
    final invoice = await ndk.zaps.fetchInvoice(
      lud16Link: Lnurl.getLud16LinkFromLud16(profile!.lud16!)!,
      amountSats: _amount!,
      zapRequest: zapRequest,
    );

    // auto pay with NWC
    final wallet = await LOGIN.value?.getWallet();
    if (wallet != null && invoice != null) {
      try {
        final preimage = await wallet.payInvoice(invoice.invoice);
        if (widget.onPaid != null) {
          widget.onPaid!(preimage);
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _pr = invoice.invoice;
        });
      }
    } else {
      setState(() {
        _pr = invoice?.invoice;
      });
    }
  }

  Widget _zapAmount(int n) {
    return GestureDetector(
      onTap: () => setState(() {
        _error = null;
        _customAmount.clear();
        _customAmountFocus.unfocus();
        _amount = n;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: n == _amount ? NEUTRAL_800 : NEUTRAL_500,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: AlignmentDirectional.center,
        child: Text(
          formatSats(n),
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
