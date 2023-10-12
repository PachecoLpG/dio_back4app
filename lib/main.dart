import 'package:dio_back4app/cep_listview_page.dart';
import 'package:dio_back4app/models/cep_model.dart';
import 'package:dio_back4app/repos/b4a_repo.dart';
import 'package:dio_back4app/repos/via_cep_repo.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const keyApplicationId = 'Me78lvjltz4LGPmYD6KeCitj21B1RY80AWljplN1';
  const keyClientKey = 'jWr1eDVR96lEPM7lw6yWf2G79XRziJfxgK5tvsEU';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController cepController =
      TextEditingController(text: '88220000');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CepModel? cepModel;

  Future<void> buscarCep() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    cepModel = await ViaCepRepo().getCep(cepController.value.text);
    setState(() {});

    if (cepModel?.cep == null) {
      if (mounted) {
        Navigator.pop(context);
      }

      return showError();
    }

    bool cadastrado = await B4aRepo().verifyCep(cepModel!.cep!);

    if (!cadastrado) {
      await B4aRepo().createCep(cepModel!);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void showError() {
    const snackBar = SnackBar(
      content: Text('Cep não encontrado'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    B4aRepo().getCepList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe um cep';
                    }

                    if (value.length != 8) {
                      return 'informe um cep valido';
                    }

                    return null;
                  },
                  controller: cepController,
                  decoration: const InputDecoration(hintText: 'Informe o cep')),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: buscarCep,
                  icon: const Icon(Icons.search),
                  label: const Text('Pesquisar cep')),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const CepListViewPage()));
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Verificar CEPS pesquisados')),
              if (cepModel != null) const Text('Último CEP pesquisado'),
              CepPesquisado(cep: cepModel),
            ],
          ),
        ),
      ),
    );
  }
}

class CepPesquisado extends StatelessWidget {
  const CepPesquisado({super.key, required this.cep});

  final CepModel? cep;

  @override
  Widget build(BuildContext context) {
    if (cep == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Text(cep!.cep ?? '-'),
          Text('${cep!.localidade ?? '-'} - ${cep!.uf ?? '-'}'),
          Text(cep!.bairro ?? ''),
        ]),
      ),
    );
  }
}
