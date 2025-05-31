import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:freeflow/main.dart';
import 'package:freeflow/theme.dart';
import 'package:freeflow/widgets/button.dart';
import 'package:freeflow/widgets/profile_name.dart';
import 'package:ndk/domain_layer/usecases/lnurl/lnurl.dart';
import 'package:ndk/ndk.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ZapWidget extends StatefulWidget {
  final String pubkey;
  final Nip01Event? target;

  ZapWidget({required this.pubkey, this.target});

  @override
  State<StatefulWidget> createState() => _ZapWidget();
}

class _ZapWidget extends State<ZapWidget> {
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
    1000000
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                "Zap",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ProfileNameWidget.pubkey(
                widget.pubkey,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (_pr == null) ..._inputs(),
          if (_pr != null) ..._invoice()
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
            childAspectRatio: 1.5,
          ),
          itemBuilder: (ctx, idx) => _zapAmount(_zapAmounts[idx])),
      TextFormField(
        decoration: InputDecoration(labelText: "Comment"),
      ),
      BasicButton.text("Zap", onTap: () {
        try {
          _loadZap();
        } catch (e) {
          setState(() {
            _error = e.toString();
          });
        }
      }),
      if (_error != null) Text(_error!)
    ];
  }

  List<Widget> _invoice() {
    return [
      QrImageView(
        data: _pr!,
        size: 256,
      ),
      GestureDetector(
        onTap: () async {
          await FlutterClipboard.copy(_pr!);
        },
        child: Text(
          _pr!,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      BasicButton.text("Open in Wallet", onTap: () async {
        try {
          await launchUrlString("lightning:${_pr!}");
        } catch (e) {
          setState(() {
            _error = e is String ? e : e.toString();
          });
        }
      }),
      if (_error != null) Text(_error!)
    ];
  }

  Future<void> _loadZap() async {
    final profile = await ndk.metadata.loadMetadata(widget.pubkey);
    if (profile?.lud16 == null) {
      throw "No lightning address found";
    }
    final signer = ndk.accounts.getLoggedAccount()?.signer;

    final zapRequest = signer != null
        ? await ndk.zaps.createZapRequest(
            amountSats: _amount!,
            signer: signer,
            pubKey: widget.pubkey,
            eventId: widget.target?.id,
            relays: DEFAULT_RELAYS)
        : null;

    final invoice = await ndk.zaps.fetchInvoice(
        lud16Link: Lnurl.getLud16LinkFromLud16(profile!.lud16!)!,
        amountSats: _amount!,
        zapRequest: zapRequest);

    setState(() {
      _pr = invoice?.invoice;
    });
  }

  Widget _zapAmount(int n) {
    return GestureDetector(
      onTap: () => setState(() {
        _amount = n;
      }),
      child: Container(
        decoration: BoxDecoration(
            color: n == _amount ? NEUTRAL_800 : NEUTRAL_500,
            borderRadius: BorderRadius.all(Radius.circular(8))),
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
