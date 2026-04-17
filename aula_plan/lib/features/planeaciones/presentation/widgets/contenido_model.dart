class ContenidoBusqueda {
  final String titulo;
  final List<String> pdas;
  final String? numero;

  ContenidoBusqueda({
    required this.titulo,
    required this.pdas,
    this.numero,
  });
}

class ContenidoPrimaria extends ContenidoBusqueda {
  final String grado;
  
  ContenidoPrimaria({
    required super.titulo,
    required super.pdas,
    required super.numero,
    required this.grado,
  });
}

class ContenidoPrescolar extends ContenidoBusqueda {
  final String grado;

  ContenidoPrescolar({
    required super.titulo,
    required super.pdas,
    required super.numero,
    required this.grado,
  });
}

class ContenidoSecundaria extends ContenidoBusqueda {
  final String grado;

  ContenidoSecundaria({
    required super.titulo,
    required super.pdas,
    required super.numero,
    required this.grado,
  });
}


