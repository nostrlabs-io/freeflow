import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freeflow/view_model/login.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class BottomBar extends StatelessWidget {
  static const double NavigationIconSize = 20.0;
  static const double CreateButtonWidth = 38.0;

  const BottomBar({Key? key}) : super(key: key);

  Widget get customCreateIcon => Container(
      width: CreateButtonWidth,
      height: 30,
      margin: EdgeInsets.only(bottom: 10),
      child: Stack(alignment: Alignment.center, children: [
        Container(
            margin: EdgeInsets.only(left: 10.0),
            width: CreateButtonWidth,
            decoration: BoxDecoration(
                color: Color.fromARGB(169, 208, 0, 255),
                borderRadius: BorderRadius.circular(7.0))),
        Container(
            margin: EdgeInsets.only(right: 10.0),
            width: CreateButtonWidth,
            decoration: BoxDecoration(
                color: Color.fromARGB(169, 0, 102, 255),
                borderRadius: BorderRadius.circular(7.0))),
        Center(
            child: Container(
          height: double.infinity,
          width: CreateButtonWidth,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(7.0)),
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 20.0,
          ),
        )),
      ]));

  @override
  Widget build(BuildContext context) {
    final login = GetIt.I.get<LoginData>();
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        children: [
          Expanded(child: menuButton(context, 'Home', "home", "/")),
          Expanded(child: menuButton(context, 'Search', "search", "/search")),
          Expanded(
            child: GestureDetector(
                onTap: () => context.push("/create"), child: customCreateIcon),
          ),
          Expanded(child: menuButton(context, 'Inbox', "inbox", "/messages")),
          Expanded(
              child: AnimatedBuilder(
                  animation: login,
                  builder: (context, data) {
                    return menuButton(context, 'Profile', "profile",
                        login.value == null ? "/login" : "/profile/me");
                  }))
        ],
      ),
    );
  }

  Widget menuButton(
      BuildContext context, String text, String icon, String path) {
    final state = GoRouterState.of(context);
    return GestureDetector(
        onTap: () {
          context.push(path);
        },
        child: Container(
          height: 46,
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                  "assets/svg/${icon}${state.fullPath == path ? "_filled" : ""}.svg"),
              SizedBox(
                height: 7,
              ),
              Text(
                text,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 11.0),
              )
            ],
          ),
        ));
  }
}
