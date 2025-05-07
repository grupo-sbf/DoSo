import 'package:example/data/data_source_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/fake_api.dart';
import 'data/repository_impl.dart';
import 'presentation/cubit.dart';
import 'presentation/screen.dart';

const appName = 'DoSo Example';

void main() {
  final http = FakeNetwork();
  final dataSource = DataSourceImpl(http);
  final repository = RepositoryImpl(dataSource);
  final cubit = MyCubit(repository);

  runApp(
    BlocProvider(
      create: (context) => cubit,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Screen(title: appName),
    );
  }
}
