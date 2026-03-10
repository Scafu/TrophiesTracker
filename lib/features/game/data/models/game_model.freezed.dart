// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameModel {

 int get appId; String get name; String? get headerImage; String? get libraryImage; List<String> get publisher; List<TrophyModel> get trophies; String? get description; DateTime? get addedAt; String get platformSource; bool get isSynced;
/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameModelCopyWith<GameModel> get copyWith => _$GameModelCopyWithImpl<GameModel>(this as GameModel, _$identity);

  /// Serializes this GameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameModel&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.name, name) || other.name == name)&&(identical(other.headerImage, headerImage) || other.headerImage == headerImage)&&(identical(other.libraryImage, libraryImage) || other.libraryImage == libraryImage)&&const DeepCollectionEquality().equals(other.publisher, publisher)&&const DeepCollectionEquality().equals(other.trophies, trophies)&&(identical(other.description, description) || other.description == description)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.platformSource, platformSource) || other.platformSource == platformSource)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,name,headerImage,libraryImage,const DeepCollectionEquality().hash(publisher),const DeepCollectionEquality().hash(trophies),description,addedAt,platformSource,isSynced);

@override
String toString() {
  return 'GameModel(appId: $appId, name: $name, headerImage: $headerImage, libraryImage: $libraryImage, publisher: $publisher, trophies: $trophies, description: $description, addedAt: $addedAt, platformSource: $platformSource, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $GameModelCopyWith<$Res>  {
  factory $GameModelCopyWith(GameModel value, $Res Function(GameModel) _then) = _$GameModelCopyWithImpl;
@useResult
$Res call({
 int appId, String name, String? headerImage, String? libraryImage, List<String> publisher, List<TrophyModel> trophies, String? description, DateTime? addedAt, String platformSource, bool isSynced
});




}
/// @nodoc
class _$GameModelCopyWithImpl<$Res>
    implements $GameModelCopyWith<$Res> {
  _$GameModelCopyWithImpl(this._self, this._then);

  final GameModel _self;
  final $Res Function(GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? name = null,Object? headerImage = freezed,Object? libraryImage = freezed,Object? publisher = null,Object? trophies = null,Object? description = freezed,Object? addedAt = freezed,Object? platformSource = null,Object? isSynced = null,}) {
  return _then(_self.copyWith(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,headerImage: freezed == headerImage ? _self.headerImage : headerImage // ignore: cast_nullable_to_non_nullable
as String?,libraryImage: freezed == libraryImage ? _self.libraryImage : libraryImage // ignore: cast_nullable_to_non_nullable
as String?,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as List<String>,trophies: null == trophies ? _self.trophies : trophies // ignore: cast_nullable_to_non_nullable
as List<TrophyModel>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,platformSource: null == platformSource ? _self.platformSource : platformSource // ignore: cast_nullable_to_non_nullable
as String,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GameModel].
extension GameModelPatterns on GameModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameModel value)  $default,){
final _that = this;
switch (_that) {
case _GameModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameModel value)?  $default,){
final _that = this;
switch (_that) {
case _GameModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int appId,  String name,  String? headerImage,  String? libraryImage,  List<String> publisher,  List<TrophyModel> trophies,  String? description,  DateTime? addedAt,  String platformSource,  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.appId,_that.name,_that.headerImage,_that.libraryImage,_that.publisher,_that.trophies,_that.description,_that.addedAt,_that.platformSource,_that.isSynced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int appId,  String name,  String? headerImage,  String? libraryImage,  List<String> publisher,  List<TrophyModel> trophies,  String? description,  DateTime? addedAt,  String platformSource,  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _GameModel():
return $default(_that.appId,_that.name,_that.headerImage,_that.libraryImage,_that.publisher,_that.trophies,_that.description,_that.addedAt,_that.platformSource,_that.isSynced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int appId,  String name,  String? headerImage,  String? libraryImage,  List<String> publisher,  List<TrophyModel> trophies,  String? description,  DateTime? addedAt,  String platformSource,  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _GameModel() when $default != null:
return $default(_that.appId,_that.name,_that.headerImage,_that.libraryImage,_that.publisher,_that.trophies,_that.description,_that.addedAt,_that.platformSource,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameModel extends GameModel {
  const _GameModel({required this.appId, required this.name, this.headerImage, this.libraryImage, final  List<String> publisher = const [], final  List<TrophyModel> trophies = const [], this.description, this.addedAt, this.platformSource = "local", this.isSynced = false}): _publisher = publisher,_trophies = trophies,super._();
  factory _GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

@override final  int appId;
@override final  String name;
@override final  String? headerImage;
@override final  String? libraryImage;
 final  List<String> _publisher;
@override@JsonKey() List<String> get publisher {
  if (_publisher is EqualUnmodifiableListView) return _publisher;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publisher);
}

 final  List<TrophyModel> _trophies;
@override@JsonKey() List<TrophyModel> get trophies {
  if (_trophies is EqualUnmodifiableListView) return _trophies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trophies);
}

@override final  String? description;
@override final  DateTime? addedAt;
@override@JsonKey() final  String platformSource;
@override@JsonKey() final  bool isSynced;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameModelCopyWith<_GameModel> get copyWith => __$GameModelCopyWithImpl<_GameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameModel&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.name, name) || other.name == name)&&(identical(other.headerImage, headerImage) || other.headerImage == headerImage)&&(identical(other.libraryImage, libraryImage) || other.libraryImage == libraryImage)&&const DeepCollectionEquality().equals(other._publisher, _publisher)&&const DeepCollectionEquality().equals(other._trophies, _trophies)&&(identical(other.description, description) || other.description == description)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.platformSource, platformSource) || other.platformSource == platformSource)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,name,headerImage,libraryImage,const DeepCollectionEquality().hash(_publisher),const DeepCollectionEquality().hash(_trophies),description,addedAt,platformSource,isSynced);

@override
String toString() {
  return 'GameModel(appId: $appId, name: $name, headerImage: $headerImage, libraryImage: $libraryImage, publisher: $publisher, trophies: $trophies, description: $description, addedAt: $addedAt, platformSource: $platformSource, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$GameModelCopyWith<$Res> implements $GameModelCopyWith<$Res> {
  factory _$GameModelCopyWith(_GameModel value, $Res Function(_GameModel) _then) = __$GameModelCopyWithImpl;
@override @useResult
$Res call({
 int appId, String name, String? headerImage, String? libraryImage, List<String> publisher, List<TrophyModel> trophies, String? description, DateTime? addedAt, String platformSource, bool isSynced
});




}
/// @nodoc
class __$GameModelCopyWithImpl<$Res>
    implements _$GameModelCopyWith<$Res> {
  __$GameModelCopyWithImpl(this._self, this._then);

  final _GameModel _self;
  final $Res Function(_GameModel) _then;

/// Create a copy of GameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appId = null,Object? name = null,Object? headerImage = freezed,Object? libraryImage = freezed,Object? publisher = null,Object? trophies = null,Object? description = freezed,Object? addedAt = freezed,Object? platformSource = null,Object? isSynced = null,}) {
  return _then(_GameModel(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,headerImage: freezed == headerImage ? _self.headerImage : headerImage // ignore: cast_nullable_to_non_nullable
as String?,libraryImage: freezed == libraryImage ? _self.libraryImage : libraryImage // ignore: cast_nullable_to_non_nullable
as String?,publisher: null == publisher ? _self._publisher : publisher // ignore: cast_nullable_to_non_nullable
as List<String>,trophies: null == trophies ? _self._trophies : trophies // ignore: cast_nullable_to_non_nullable
as List<TrophyModel>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,platformSource: null == platformSource ? _self.platformSource : platformSource // ignore: cast_nullable_to_non_nullable
as String,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
