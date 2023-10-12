import 'package:dio_back4app/models/cep_model.dart';
import 'package:dio_back4app/repos/b4a_repo.dart';
import 'package:flutter/material.dart';

class CepListViewPage extends StatefulWidget {
  const CepListViewPage({super.key});

  @override
  State<CepListViewPage> createState() => _CepListViewPageState();
}

class _CepListViewPageState extends State<CepListViewPage> {
  Future<List<CepModel>>? cepList;
  TextEditingController editController = TextEditingController();

  @override
  void initState() {
    super.initState();

    cepList = B4aRepo().getCepList();
  }

  Future<void> onRefresh() async {
    setState(() {
      cepList = B4aRepo().getCepList();
    });
  }

  Future<void> deleteCep(String id) async {
    await B4aRepo().delete(id);
  }

  Future<void> editCep(String id) async {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Alterar logradouro'),
              content: TextField(
                controller: editController,
              ),
              actions: [
                ElevatedButton.icon(
                    onPressed: () async {
                      await B4aRepo().edit(id, editController.text);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Editado com sucesso'),
                          ),
                        );

                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'))
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: FutureBuilder(
              future: cepList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Text('Nenhum item encontrado');
                  }

                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!
                          .map((cep) => CepTile(
                                cep: cep,
                                delete: deleteCep,
                                edit: editCep,
                              ))
                          .toList(),
                    );
                  }
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}

class CepTile extends StatelessWidget {
  const CepTile({
    super.key,
    required this.cep,
    required this.delete,
    required this.edit,
  });

  final CepModel cep;
  final Future<void> Function(String) delete;
  final Future<void> Function(String) edit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cep.cep ?? '-'),
      subtitle: Text('${cep.localidade ?? '-'} - ${cep.uf ?? '-'}'),
      leading: IconButton(
        onPressed: () async {
          await delete(cep.objectId!);
          if (context.mounted) {
            context
                .findAncestorStateOfType<_CepListViewPageState>()!
                .onRefresh();
          }
        },
        icon: const Icon(Icons.close),
      ),
      trailing: IconButton(
        onPressed: () async {
          await edit(cep.objectId!);
        },
        icon: const Icon(Icons.edit),
      ),
    );
  }
}
