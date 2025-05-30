import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyCubit>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocBuilder<MyCubit, MyState>(
              builder: (context, state) => state.when(
                onInitial: () => const Text('Initial State'),
                onLoading: () => const CircularProgressIndicator(),
                onSuccess: (data) => Text(
                  data,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                onFailure: (failure) => Text(
                  failure.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: cubit.getOk,
              child: const Text('Success'),
            ),
            ElevatedButton(
              onPressed: cubit.getNotFound,
              child: const Text('Not Found'),
            ),
            ElevatedButton(
              onPressed: cubit.getInternalServer,
              child: const Text('Internal Error'),
            ),
          ],
        ),
      ),
    );
  }
}
