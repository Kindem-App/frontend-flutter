import 'package:flutter/widgets.dart';
import 'package:flutter_app_stulish/helpers/sizes_helpers.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonFriendList extends StatelessWidget {
  const SkeletonFriendList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SkeletonItem(context),
          SkeletonItem(context),
          SkeletonItem(context),
          SkeletonItem(context),
          SkeletonItem(context),
        ],
      ),
    );
  }

  Widget SkeletonItem(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: displayHeight(context) * 0.01,
          bottom: displayHeight(context) * 0.01,
          left: displayWidth(context) * 0.05),
      child: Container(
        width: displayWidth(context) * 1,
        height: displayHeight(context) * 0.1,
        child: Row(
          children: [
            SkeletonAvatar(
                style: SkeletonAvatarStyle(
                    width: displayWidth(context) * 0.12,
                    height: displayHeight(context) * 0.07)),
            Padding(
              padding: EdgeInsets.only(
                left: displayWidth(context) * 0.03,
              ),
              child: Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                              width: displayWidth(context) * 0.4, height: 20)),
                      Padding(
                          padding: EdgeInsets.only(
                              top: displayHeight(context) * 0.01),
                          child: SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                                  width: displayWidth(context) * 0.55,
                                  height: 20))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
