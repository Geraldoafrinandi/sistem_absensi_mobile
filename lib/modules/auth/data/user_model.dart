class UserModel {
  final int idUser;
  final int idMahasiswa;
  final String nim;
  final String namaUser;
  final int kelasId;
  final String role;

  UserModel({
    required this.idUser,
    required this.idMahasiswa,
    required this.nim,
    required this.namaUser,
    required this.kelasId,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'],
      idMahasiswa: json['id_mahasiswa'],
      nim: json['nim'],
      namaUser: json['nama_user'],
      kelasId: json['kelas_id'],
      role: json['role'],
    );
  }
}