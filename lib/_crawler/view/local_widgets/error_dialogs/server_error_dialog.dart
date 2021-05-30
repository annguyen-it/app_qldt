import 'package:app_qldt/_crawler/bloc/crawler_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServerErrorDialog extends StatelessWidget {
  final BuildContext rootContext;

  const ServerErrorDialog({
    Key? key,
    required this.rootContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 5.0),
      content: Text('Lỗi hệ thống, vui lòng thử lại sau'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            rootContext.read<CrawlerBloc>().add(CrawlerResetStatus());
          },
          child: Text('Đồng ý'),
        ),
      ],
    );
  }
}
