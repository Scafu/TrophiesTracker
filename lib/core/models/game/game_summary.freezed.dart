// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameSummary {

 int get appid; String get name;
/// Create a copy of GameSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSummaryCopyWith<GameSummary> get copyWith => _$GameSummaryCopyWithImpl<GameSummary>(this as GameSummary, _$identity);

  /// Serializes this GameSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSummary&&(identical(other.appid, appid) || other.appid == appid)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appid,name);

@override
String toString() {
  return 'GameSummary(appid: $appid, name: $name)';
}


}

/// @nodoc
abstract mixin class $GameSummaryCopyWith<$Res>  {
  factory $GameSummaryCopyWith(GameSummary value, $Res Function(GameSummary) _then) = _$GameSummaryCopyWithImpl;
@useResult
$Res call({
 int appid, String name
});




}
/// @nodoc
class _$GameSummaryCopyWithImpl<$Res>
    implements $GameSummaryCopyWith<$Res> {
  _$GameSummaryCopyWithImpl(this._self, this._then);

  final GameSummary _self;
  final $Res Function(GameSummary) _then;

/// Create a copy of GameSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appid = null,Object? name = null,}) {
  return _then(_self.copyWith(
appid: null == appid ? _self.appid : appid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GameSummary].
extension GameSummaryPatterns on GameSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameSummary value)  $default,){
final _that = this;
switch (_that) {
case _GameSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameSummary value)?  $default,){
final _that = this;
switch (_that) {
case _GameSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int appid,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameSummary() when $default != null:
return $default(_that.appid,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int appid,  String name)  $default,) {final _that = this;
switch (_that) {
case _GameSummary():
return $default(_that.appid,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int appid,  String name)?  $default,) {final _that = this;
switch (_that) {
case _GameSummary() when $default != null:
return $default(_that.appid,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameSummary implements GameSummary {
  const _GameSummary({required this.appid, required this.name});
  factory _GameSummary.fromJson(Map<String, dynamic> json) => _$GameSummaryFromJson(json);

@override final  int appid;
@override final  String name;

/// Create a copy of GameSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSummaryCopyWith<_GameSummary> get copyWith => __$GameSummaryCopyWithImpl<_GameSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSummary&&(identical(other.appid, appid) || other.appid == appid)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appid,name);

@override
String toString() {
  return 'GameSummary(appid: $appid, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GameSummaryCopyWith<$Res> implements $GameSummaryCopyWith<$Res> {
  factory _$GameSummaryCopyWith(_GameSummary value, $Res Function(_GameSummary) _then) = __$GameSummaryCopyWithImpl;
@override @useResult
$Res call({
 int appid, String name
});




}
/// @nodoc
class __$GameSummaryCopyWithImpl<$Res>
    implements _$GameSummaryCopyWith<$Res> {
  __$GameSummaryCopyWithImpl(this._self, this._then);

  final _GameSummary _self;
  final $Res Function(_GameSummary) _then;

/// Create a copy of GameSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? appid = null,Object? name = null,}) {
  return _then(_GameSummary(
appid: null == appid ? _self.appid : appid // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
