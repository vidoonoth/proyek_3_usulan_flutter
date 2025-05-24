class Config {
  static const String ip = '192.168.1.34:8000';

  // Untuk endpoint API
  static String baseUrl(String path) => 'http://$ip/api/$path';

  // Untuk path gambar usulan
  static String fixImageUrl(String url) {
    if (url.contains('usulan/usulan/')) {
      // Perbaiki URL dengan menghapus duplikasi 'usulan/usulan/'
      return url.replaceFirst('usulan/usulan/', 'usulan/');
    }
    return url;
  }


  // static String usulanImageUrl(String? path) {
  //   if (path == null || path.isEmpty) return '';
  //   // Jika path sudah berupa URL lengkap, kembalikan langsung
  //   if (path.startsWith('http')) return path;
  //   // Jika hanya nama file, proses menjadi URL lengkap
  //   return 'http://$ip/storage/usulan/$path';
  // }
}