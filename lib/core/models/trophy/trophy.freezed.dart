// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trophy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trophy {

 String get displayName; String? get description; int get isAchieved; String? get coloredIcon; String? get uncoloredIcon; DateTime? get achievedAt;
/// Create a copy of Trophy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrophyCopyWith<Trophy> get copyWith => _$TrophyCopyWithImpl<Trophy>(this as Trophy, _$identity);

  /// Serializes this Trophy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trophy&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.isAchieved, isAchieved) || other.isAchieved == isAchieved)&&(identical(other.coloredIcon, coloredIcon) || other.coloredIcon == coloredIcon)&&(identical(other.uncoloredIcon, uncoloredIcon) || other.uncoloredIcon == uncoloredIcon)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,description,isAchieved,coloredIcon,uncoloredIcon,achievedAt);

@override
String toString() {
  return 'Trophy(displayName: $displayName, description: $description, isAchieved: $isAchieved, coloredIcon: $coloredIcon, uncoloredIcon: $uncoloredIcon, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $TrophyCopyWith<$Res>  {
  factory $TrophyCopyWith(Trophy value, $Res Function(Trophy) _then) = _$TrophyCopyWithImpl;
@useResult
$Res call({
 String displayName, String? description, int isAchieved, String? coloredIcon, String? uncoloredIcon, DateTime? achievedAt
});




}
/// @nodoc
class _$TrophyCopyWithImpl<$Res>
    implements $TrophyCopyWith<$Res> {
  _$TrophyCopyWithImpl(this._self, this._then);

  final Trophy _self;
  final $Res Function(Trophy) _then;

/// Create a copy of Trophy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? description = freezed,Object? isAchieved = null,Object? coloredIcon = freezed,Object? uncoloredIcon = freezed,Object? achievedAt = freezed,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isAchieved: null == isAchieved ? _self.isAchieved : isAchieved // ignore: cast_nullable_to_non_nullable
as int,coloredIcon: freezed == coloredIcon ? _self.coloredIcon : coloredIcon // ignore: cast_nullable_to_non_nullable
as String?,uncoloredIcon: freezed == uncoloredIcon ? _self.uncoloredIcon : uncoloredIcon // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Trophy].
extension TrophyPatterns on Trophy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trophy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trophy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trophy value)  $default,){
final _that = this;
switch (_that) {
case _Trophy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trophy value)?  $default,){
final _that = this;
switch (_that) {
case _Trophy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName,  String? description,  int isAchieved,  String? coloredIcon,  String? uncoloredIcon,  DateTime? achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trophy() when $default != null:
return $default(_that.displayName,_that.description,_that.isAchieved,_that.coloredIcon,_that.uncoloredIcon,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName,  String? description,  int isAchieved,  String? coloredIcon,  String? uncoloredIcon,  DateTime? achievedAt)  $default,) {final _that = this;
switch (_that) {
case _Trophy():
return $default(_that.displayName,_that.description,_that.isAchieved,_that.coloredIcon,_that.uncoloredIcon,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName,  String? description,  int isAchieved,  String? coloredIcon,  String? uncoloredIcon,  DateTime? achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _Trophy() when $default != null:
return $default(_that.displayName,_that.description,_that.isAchieved,_that.coloredIcon,_that.uncoloredIcon,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trophy implements Trophy {
  const _Trophy({required this.displayName, this.description, this.isAchieved = 0, this.coloredIcon, this.uncoloredIcon, this.achievedAt});
  factory _Trophy.fromJson(Map<String, dynamic> json) => _$TrophyFromJson(json);

@override final  String displayName;
@override final  String? description;
@override@JsonKey() final  int isAchieved;
@override final  String? coloredIcon;
@override final  String? uncoloredIcon;
@override final  DateTime? achievedAt;

/// Create a copy of Trophy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrophyCopyWith<_Trophy> get copyWith => __$TrophyCopyWithImpl<_Trophy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrophyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trophy&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.isAchieved, isAchieved) || other.isAchieved == isAchieved)&&(identical(other.coloredIcon, coloredIcon) || other.coloredIcon == coloredIcon)&&(identical(other.uncoloredIcon, uncoloredIcon) || other.uncoloredIcon == uncoloredIcon)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,description,isAchieved,coloredIcon,uncoloredIcon,achievedAt);

@override
String toString() {
  return 'Trophy(displayName: $displayName, description: $description, isAchieved: $isAchieved, coloredIcon: $coloredIcon, uncoloredIcon: $uncoloredIcon, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$TrophyCopyWith<$Res> implements $TrophyCopyWith<$Res> {
  factory _$TrophyCopyWith(_Trophy value, $Res Function(_Trophy) _then) = __$TrophyCopyWithImpl;
@override @useResult
$Res call({
 String displayName, String? description, int isAchieved, String? coloredIcon, String? uncoloredIcon, DateTime? achievedAt
});




}
/// @nodoc
class __$TrophyCopyWithImpl<$Res>
    implements _$TrophyCopyWith<$Res> {
  __$TrophyCopyWithImpl(this._self, this._then);

  final _Trophy _self;
  final $Res Function(_Trophy) _then;

/// Create a copy of Trophy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? description = freezed,Object? isAchieved = null,Object? coloredIcon = freezed,Object? uncoloredIcon = freezed,Object? achievedAt = freezed,}) {
  return _then(_Trophy(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isAchieved: null == isAchieved ? _self.isAchieved : isAchieved // ignore: cast_nullable_to_non_nullable
as int,coloredIcon: freezed == coloredIcon ? _self.coloredIcon : coloredIcon // ignore: cast_nullable_to_non_nullable
as String?,uncoloredIcon: freezed == uncoloredIcon ? _self.uncoloredIcon : uncoloredIcon // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
