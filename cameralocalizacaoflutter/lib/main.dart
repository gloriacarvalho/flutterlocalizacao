
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const PerfilApp());
}

class PerfilApp extends StatelessWidget {
  const PerfilApp({super.key});

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF39796B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu Perfil',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F7),
          foregroundColor: Color(0xFF24332F),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const TelaPerfil(),
    );
  }
}

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final ImagePicker _picker = ImagePicker();

  File? _foto;

  String _localizacao = 'Sua localização aparecerá aqui.';

  bool _localizacaoObtida = false;
  bool _buscandoLocalizacao = false;

  // Abre a câmera ou a galeria.
  Future<void> _escolherFoto(ImageSource origem) async {
    try {
      final XFile? imagem = await _picker.pickImage(
        source: origem,
        imageQuality: 85,
      );

      if (!mounted || imagem == null) return;

      setState(() {
        _foto = File(imagem.path);
      });
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível abrir a imagem. Tente novamente.',
          ),
        ),
      );
    }
  }

  // Obtém a localização atual.
  Future<void> _obterLocalizacao() async {
    if (_buscandoLocalizacao) return;

    setState(() {
      _buscandoLocalizacao = true;
      _localizacaoObtida = false;
      _localizacao = 'Obtendo sua localização...';
    });

    try {
      // Verifica se o serviço de localização está ativo.
      final bool servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        _mostrarErro('Ative o GPS do dispositivo.');
        return;
      }

      // Verifica e solicita a permissão.
      LocationPermission permissao =
          await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        _mostrarErro(
          'Permissão de localização negada. '
          'Autorize o acesso para continuar.',
        );
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        _mostrarErro(
          'A permissão foi bloqueada. '
          'Libere a localização nas configurações do aplicativo.',
        );
        return;
      }

      if (!mounted) return;

      // Busca as coordenadas com limite de tempo.
      final Position posicao =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      if (!mounted) return;

      setState(() {
        _localizacao =
            'Latitude: ${posicao.latitude.toStringAsFixed(4)}\n'
            'Longitude: ${posicao.longitude.toStringAsFixed(4)}';

        _localizacaoObtida = true;
        _buscandoLocalizacao = false;
      });
    } catch (erro) {
      _mostrarErro(
        'Não foi possível obter a localização. '
        'Verifique o GPS e tente novamente.',
      );
    }
  }

  // Atualiza a interface quando ocorre um erro.
  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    setState(() {
      _localizacao = mensagem;
      _localizacaoObtida = false;
      _buscandoLocalizacao = false;
    });
  }

  // Remove a foto do perfil.
  void _removerFoto() {
    setState(() {
      _foto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF39796B);
    const textoEscuro = Color(0xFF24332F);
    const textoSecundario = Color(0xFF718078);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu perfil',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Seu espaço pessoal',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: textoEscuro,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Gerencie sua foto e consulte sua localização atual.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: textoSecundario,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Foto de perfil circular.
                  Center(
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: const Color(0xFFE2ECE8),
                      backgroundImage: _foto != null
                          ? FileImage(_foto!)
                          : null,
                      child: _foto == null
                          ? const Icon(
                              Icons.person_outline,
                              size: 66,
                              color: verde,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Botão da câmera.
                  ElevatedButton.icon(
                    onPressed: () =>
                        _escolherFoto(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Tirar foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verde,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botão da galeria.
                  OutlinedButton.icon(
                    onPressed: () =>
                        _escolherFoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Escolher da galeria'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: verde,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(
                        color: Color(0xFFD4E0DB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (_foto != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: _removerFoto,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remover foto'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Cartão de localização.
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE6EBE8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2EE),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _localizacaoObtida
                                    ? Icons.location_on_outlined
                                    : Icons.location_searching,
                                color: verde,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Localização atual',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textoEscuro,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Coordenadas do dispositivo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          _localizacao,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.8,
                            color: textoEscuro,
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _buscandoLocalizacao
                                ? null
                                : _obterLocalizacao,
                            icon: _buscandoLocalizacao
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                            label: Text(
                              _buscandoLocalizacao
                                  ? 'Obtendo localização...'
                                  : 'Obter localização',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: verde,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
