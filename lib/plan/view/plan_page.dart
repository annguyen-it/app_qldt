import 'package:app_qldt/_widgets/list_tile/custom_list_tile.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:app_qldt/plan/plan.dart';
import 'package:app_qldt/_utils/helper/day_of_week_vn.dart';
import 'package:app_qldt/_widgets/model/inherited_scroll_to_plan_page.dart';

import 'local_widgets/local_widgets.dart';

class PlanPage extends StatefulWidget {
  final DateTime? from;
  final DateTime? to;
  final ScrollController? scrollController;
  final Function()? onCloseButtonTap;

  PlanPage({
    Key? key,
    this.from,
    this.to,
    this.scrollController,
    this.onCloseButtonTap,
  }) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PlanBloc, PlanState>(
      listener: (context, state) async {
        PanelController panelController = InheritedScrollToPlanPage.of(context).panelController;

        if (state.visibility == PlanPageVisibility.close && !panelController.isPanelClosed) {
          await panelController.close();
        } else if (state.visibility == PlanPageVisibility.open && !panelController.isPanelOpen) {
          await panelController.open();
        } else if (state.visibility == PlanPageVisibility.apart &&
            panelController.panelPosition != 0.3) {
          await panelController.animatePanelToPosition(0.3);
        }
      },
      child: Scaffold(
        body: BlocBuilder<PlanBloc, PlanState>(
          buildWhen: (previous, current) =>
              previous.fromDay != current.fromDay || previous.visibility != current.visibility,
          builder: (context, state) {
            if (state.visibility == PlanPageVisibility.open) {
              return _FullPlanPage(onCloseButtonTap: widget.onCloseButtonTap);
            }

            return _ApartPlanPage(onCloseButtonTap: widget.onCloseButtonTap);
          },
        ),
      ),
    );
  }
}

class _FullPlanPage extends StatefulWidget {
  final ScrollController? scrollController;
  final Function()? onCloseButtonTap;

  _FullPlanPage({
    Key? key,
    this.scrollController,
    this.onCloseButtonTap,
  }) : super(key: key);

  @override
  _FullPlanPageState createState() => _FullPlanPageState();
}

class _FullPlanPageState extends State<_FullPlanPage> {
  @override
  Widget build(BuildContext contexts) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Image.asset(
                'images/icon/swipe-down-icon.png',
                width: 40,
              ),
            ),
            PlanPageTopbar(onCloseButtonTap: widget.onCloseButtonTap),
          ],
        ),
        Expanded(
          child: BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) {
              return ListView(
                controller: widget.scrollController,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  PlanPageTime(),
                  PlanPageDivider(context: context),
                  AddGuest(),
                  PlanPageDivider(context: context),
                  Location(),
                  PlanPageDivider(context: context),
                  Describe(),
                  PlanPageDivider(context: context),
                  Accessibility(),
                  PlanPageDivider(context: context),
                  Status(),
                  PlanPageDivider(context: context),
                  PlanColor(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ApartPlanPage extends StatefulWidget {
  final Function()? onCloseButtonTap;

  const _ApartPlanPage({
    Key? key,
    this.onCloseButtonTap,
  }) : super(key: key);

  @override
  __ApartPlanPageState createState() => __ApartPlanPageState();
}

class __ApartPlanPageState extends State<_ApartPlanPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.3,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _onTap,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Image.asset(
                'images/icon/minimize-icon.png',
                width: 80,
              ),
            ),
            PlanPageTopbar(onCloseButtonTap: widget.onCloseButtonTap),
            CustomListTile(
              title: Text(
                'Thêm tiêu đề',
                style: PlanPageConstant.hintTextFieldStyle.copyWith(fontSize: 25),
              ),
              defaultHeight: false,
            ),
            CustomListTile(
              title: Padding(
                padding: EdgeInsets.only(top: 15),
                child: BlocBuilder<PlanBloc, PlanState>(
                  builder: (context, state) {
                    return Text(
                      '${DayOfWeekVN.get(state.fromDay.weekday)}, ngày ${state.fromDay.day} '
                      'tháng ${state.fromDay.month} · ${state.fromDay.hour}:00 - ${state.toDay.hour}:00',
                      style: PlanPageConstant.textFieldStyle,
                    );
                  },
                ),
              ),
              defaultHeight: false,
            ),
            CustomListTile(
              leading: Icon(Icons.people_alt_outlined),
              title: Text(
                'Thêm người',
                style: PlanPageConstant.hintTextFieldStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() {
    context.read<PlanBloc>().add(PlanPageVisibilityChanged(PlanPageVisibility.open));
  }
}
