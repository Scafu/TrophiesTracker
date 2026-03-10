// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'steam_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SteamUserModel {

 String get steamId; String? get personaName; String? get avatarUrl; String? get token;
/// Create a copy of SteamUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SteamUserModelCopyWith<SteamUserModel> get copyWith => _$SteamUserModelCopyWithImpl<SteamUserModel>(this as SteamUserModel, _$identity);

  /// Serializes this SteamUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SteamUserModel&&(identical(other.steamId, steamId) || other.steamId == steamId)&&(identical(other.personaName, personaName) || other.personaName == personaName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,steamId,personaName,avatarUrl,token);

@override
String toString() {
  return 'SteamUserModel(steamId: $steamId, personaName: $personaName, avatarUrl: $avatarUrl, token: $token)';
}


}

/// @nodoc
abstract mixin class $SteamUserModelCopyWith<$Res>  {
  factory $SteamUserModelCopyWith(SteamUserModel value, $Res Function(SteamUserModel) _then) = _$SteamUserModelCopyWithImpl;
@useResult
$Res call({
 String steamId, String? personaName, String? avatarUrl, String? token
});




}
/// @nodoc
class _$SteamUserModelCopyWithImpl<$Res>
    implements $SteamUserModelCopyWith<$Res> {
  _$SteamUserModelCopyWithImpl(this._self, this._then);

  final SteamUserModel _self;
  final $Res Function(SteamUserModel) _then;

/// Create a copy of SteamUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? steamId = null,Object? personaName = freezed,Object? avatarUrl = freezed,Object? token = freezed,}) {
  return _then(_self.copyWith(
steamId: null == steamId ? _self.steamId : steamId // ignore: cast_nullable_to_non_nullable
as String,personaName: freezed == personaName ? _self.personaName : personaName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SteamUserModel].
extension SteamUserModelPatterns on SteamUserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SteamUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SteamUserModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SteamUserModel value)  $default,){
final _that = this;
switch (_that) {
case _SteamUserModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SteamUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _SteamUserModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String steamId,  String? personaName,  String? avatarUrl,  String? token)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SteamUserModel() when $default != null:
return $default(_that.steamId,_that.personaName,_that.avatarUrl,_that.token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String steamId,  String? personaName,  String? avatarUrl,  String? token)  $default,) {final _that = this;
switch (_that) {
case _SteamUserModel():
return $default(_that.steamId,_that.personaName,_that.avatarUrl,_that.token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String steamId,  String? personaName,  String? avatarUrl,  String? token)?  $default,) {final _that = this;
switch (_that) {
case _SteamUserModel() when $default != null:
return $default(_that.steamId,_that.personaName,_that.avatarUrl,_that.token);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SteamUserModel extends SteamUserModel {
  const _SteamUserModel({required this.steamId, this.personaName, this.avatarUrl, this.token}): super._();
  factory _SteamUserModel.fromJson(Map<String, dynamic> json) => _$SteamUserModelFromJson(json);

@override final  String steamId;
@override final  String? personaName;
@override final  String? avatarUrl;
@override final  String? token;

/// Create a copy of SteamUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SteamUserModelCopyWith<_SteamUserModel> get copyWith => __$SteamUserModelCopyWithImpl<_SteamUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SteamUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SteamUserModel&&(identical(other.steamId, steamId) || other.steamId == steamId)&&(identical(other.personaName, personaName) || other.personaName == personaName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.token, token) || other.token == token));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,steamId,personaName,avatarUrl,token);

@override
String toString() {
  return 'SteamUserModel(steamId: $steamId, personaName: $personaName, avatarUrl: $avatarUrl, token: $token)';
}


}

/// @nodoc
abstract mixin class _$SteamUserModelCopyWith<$Res> implements $SteamUserModelCopyWith<$Res> {
  factory _$SteamUserModelCopyWith(_SteamUserModel value, $Res Function(_SteamUserModel) _then) = __$SteamUserModelCopyWithImpl;
@override @useResult
$Res call({
 String steamId, String? personaName, String? avatarUrl, String? token
});




}
/// @nodoc
class __$SteamUserModelCopyWithImpl<$Res>
    implements _$SteamUserModelCopyWith<$Res> {
  __$SteamUserModelCopyWithImpl(this._self, this._then);

  final _SteamUserModel _self;
  final $Res Function(_SteamUserModel) _then;

/// Create a copy of SteamUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? steamId = null,Object? personaName = freezed,Object? avatarUrl = freezed,Object? token = freezed,}) {
  return _then(_SteamUserModel(
steamId: null == steamId ? _self.steamId : steamId // ignore: cast_nullable_to_non_nullable
as String,personaName: freezed == personaName ? _self.personaName : personaName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
