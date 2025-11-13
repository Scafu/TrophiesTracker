// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Game {

 int get appId; String get name; List<String> get publisher; String? get description; String? get headerImage; String? get libraryImage; DateTime? get addedAt; List<Trophy> get trophies;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.publisher, publisher)&&(identical(other.description, description) || other.description == description)&&(identical(other.headerImage, headerImage) || other.headerImage == headerImage)&&(identical(other.libraryImage, libraryImage) || other.libraryImage == libraryImage)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&const DeepCollectionEquality().equals(other.trophies, trophies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,name,const DeepCollectionEquality().hash(publisher),description,headerImage,libraryImage,addedAt,const DeepCollectionEquality().hash(trophies));

@override
String toString() {
  return 'Game(appId: $appId, name: $name, publisher: $publisher, description: $description, headerImage: $headerImage, libraryImage: $libraryImage, addedAt: $addedAt, trophies: $trophies)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 int appId, String name, List<String> publisher, String? description, String? headerImage, String? libraryImage, DateTime? addedAt, List<Trophy> trophies
});




}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appId = null,Object? name = null,Object? publisher = null,Object? description = freezed,Object? headerImage = freezed,Object? libraryImage = freezed,Object? addedAt = freezed,Object? trophies = null,}) {
  return _then(_self.copyWith(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,headerImage: freezed == headerImage ? _self.headerImage : headerImage // ignore: cast_nullable_to_non_nullable
as String?,libraryImage: freezed == libraryImage ? _self.libraryImage : libraryImage // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trophies: null == trophies ? _self.trophies : trophies // ignore: cast_nullable_to_non_nullable
as List<Trophy>,
  ));
}

}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Game value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Game value)  $default,){
final _that = this;
switch (_that) {
case _Game():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Game value)?  $default,){
final _that = this;
switch (_that) {
case _Game() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int appId,  String name,  List<String> publisher,  String? description,  String? headerImage,  String? libraryImage,  DateTime? addedAt,  List<Trophy> trophies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.appId,_that.name,_that.publisher,_that.description,_that.headerImage,_that.libraryImage,_that.addedAt,_that.trophies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int appId,  String name,  List<String> publisher,  String? description,  String? headerImage,  String? libraryImage,  DateTime? addedAt,  List<Trophy> trophies)  $default,) {final _that = this;
switch (_that) {
case _Game():
return $default(_that.appId,_that.name,_that.publisher,_that.description,_that.headerImage,_that.libraryImage,_that.addedAt,_that.trophies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int appId,  String name,  List<String> publisher,  String? description,  String? headerImage,  String? libraryImage,  DateTime? addedAt,  List<Trophy> trophies)?  $default,) {final _that = this;
switch (_that) {
case _Game() when $default != null:
return $default(_that.appId,_that.name,_that.publisher,_that.description,_that.headerImage,_that.libraryImage,_that.addedAt,_that.trophies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Game implements Game {
  const _Game({required this.appId, required this.name, final  List<String> publisher = const [], this.description, this.headerImage, this.libraryImage, this.addedAt, final  List<Trophy> trophies = const []}): _publisher = publisher,_trophies = trophies;
  factory _Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

@override final  int appId;
@override final  String name;
 final  List<String> _publisher;
@override@JsonKey() List<String> get publisher {
  if (_publisher is EqualUnmodifiableListView) return _publisher;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publisher);
}

@override final  String? description;
@override final  String? headerImage;
@override final  String? libraryImage;
@override final  DateTime? addedAt;
 final  List<Trophy> _trophies;
@override@JsonKey() List<Trophy> get trophies {
  if (_trophies is EqualUnmodifiableListView) return _trophies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trophies);
}


/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameCopyWith<_Game> get copyWith => __$GameCopyWithImpl<_Game>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Game&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._publisher, _publisher)&&(identical(other.description, description) || other.description == description)&&(identical(other.headerImage, headerImage) || other.headerImage == headerImage)&&(identical(other.libraryImage, libraryImage) || other.libraryImage == libraryImage)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&const DeepCollectionEquality().equals(other._trophies, _trophies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appId,name,const DeepCollectionEquality().hash(_publisher),description,headerImage,libraryImage,addedAt,const DeepCollectionEquality().hash(_trophies));

@override
String toString() {
  return 'Game(appId: $appId, name: $name, publisher: $publisher, description: $description, headerImage: $headerImage, libraryImage: $libraryImage, addedAt: $addedAt, trophies: $trophies)';
}


}

/// @nodoc
abstract mixin class _$GameCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$GameCopyWith(_Game value, $Res Function(_Game) _then) = __$GameCopyWithImpl;
@override @useResult
$Res call({
 int appId, String name, List<String> publisher, String? description, String? headerImage, String? libraryImage, DateTime? addedAt, List<Trophy> trophies
});




}
/// @nodoc
class __$GameCopyWithImpl<$Res>
    implements _$GameCopyWith<$Res> {
  __$GameCopyWithImpl(this._self, this._then);

  final _Game _self;
  final $Res Function(_Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appId = null,Object? name = null,Object? publisher = null,Object? description = freezed,Object? headerImage = freezed,Object? libraryImage = freezed,Object? addedAt = freezed,Object? trophies = null,}) {
  return _then(_Game(
appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,publisher: null == publisher ? _self._publisher : publisher // ignore: cast_nullable_to_non_nullable
as List<String>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,headerImage: freezed == headerImage ? _self.headerImage : headerImage // ignore: cast_nullable_to_non_nullable
as String?,libraryImage: freezed == libraryImage ? _self.libraryImage : libraryImage // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,trophies: null == trophies ? _self._trophies : trophies // ignore: cast_nullable_to_non_nullable
as List<Trophy>,
  ));
}


}

// dart format on
