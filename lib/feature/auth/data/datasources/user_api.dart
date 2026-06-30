import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/me.dart';
import '../models/profile_image_response.dart';

part 'user_api.g.dart';

/// 사용자 API 경로 — 공통 prefix([ApiEndpoints.users])를 합성한다.
class _Endpoints {
  _Endpoints._();

  static const String me = '${ApiEndpoints.users}/me';
  static const String profileImage = '${ApiEndpoints.users}/me/profile-image';
}

/// Flooding 백엔드 사용자(`/users`) API.
///
/// `Authorization` 헤더(Bearer)는 클라이언트 인터셉터가 주입한다.
@RestApi()
abstract class UserApi {
  factory UserApi(Dio dio, {String? baseUrl}) = _UserApi;

  /// 내 정보 조회 — 세션 유효성 검사에 사용한다(401 시 미인증).
  @GET(_Endpoints.me)
  Future<MeResponse> getMe();

  /// 프로필 사진 업로드 — multipart/form-data(필드명 `image`).
  /// 응답의 `data.profileImageUrl` 을 이후 표시에 사용한다.
  @POST(_Endpoints.profileImage)
  @MultiPart()
  Future<ProfileImageResponse> uploadProfileImage(
    @Part(name: 'image') File image,
  );
}
