import 'package:flutter/material.dart';

class callPage extends StatelessWidget {
  const callPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Center(child: Text('Not Done Yet Screen',style: Theme.of(context).textTheme.bodyMedium,),),
    );
  }
}
