// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trophy_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrophyModel {

 String get apiName; String get displayName; String? get description; String? get icon; String? get coloredIcon; bool get isAchieved; DateTime? get achievedAt;
/// Create a copy of TrophyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrophyModelCopyWith<TrophyModel> get copyWith => _$TrophyModelCopyWithImpl<TrophyModel>(this as TrophyModel, _$identity);

  /// Serializes this TrophyModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrophyModel&&(identical(other.apiName, apiName) || other.apiName == apiName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.coloredIcon, coloredIcon) || other.coloredIcon == coloredIcon)&&(identical(other.isAchieved, isAchieved) || other.isAchieved == isAchieved)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apiName,displayName,description,icon,coloredIcon,isAchieved,achievedAt);

@override
String toString() {
  return 'TrophyModel(apiName: $apiName, displayName: $displayName, description: $description, icon: $icon, coloredIcon: $coloredIcon, isAchieved: $isAchieved, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $TrophyModelCopyWith<$Res>  {
  factory $TrophyModelCopyWith(TrophyModel value, $Res Function(TrophyModel) _then) = _$TrophyModelCopyWithImpl;
@useResult
$Res call({
 String apiName, String displayName, String? description, String? icon, String? coloredIcon, bool isAchieved, DateTime? achievedAt
});




}
/// @nodoc
class _$TrophyModelCopyWithImpl<$Res>
    implements $TrophyModelCopyWith<$Res> {
  _$TrophyModelCopyWithImpl(this._self, this._then);

  final TrophyModel _self;
  final $Res Function(TrophyModel) _then;

/// Create a copy of TrophyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? apiName = null,Object? displayName = null,Object? description = freezed,Object? icon = freezed,Object? coloredIcon = freezed,Object? isAchieved = null,Object? achievedAt = freezed,}) {
  return _then(_self.copyWith(
apiName: null == apiName ? _self.apiName : apiName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,coloredIcon: freezed == coloredIcon ? _self.coloredIcon : coloredIcon // ignore: cast_nullable_to_non_nullable
as String?,isAchieved: null == isAchieved ? _self.isAchieved : isAchieved // ignore: cast_nullable_to_non_nullable
as bool,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrophyModel].
extension TrophyModelPatterns on TrophyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrophyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrophyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrophyModel value)  $default,){
final _that = this;
switch (_that) {
case _TrophyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrophyModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrophyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String apiName,  String displayName,  String? description,  String? icon,  String? coloredIcon,  bool isAchieved,  DateTime? achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrophyModel() when $default != null:
return $default(_that.apiName,_that.displayName,_that.description,_that.icon,_that.coloredIcon,_that.isAchieved,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String apiName,  String displayName,  String? description,  String? icon,  String? coloredIcon,  bool isAchieved,  DateTime? achievedAt)  $default,) {final _that = this;
switch (_that) {
case _TrophyModel():
return $default(_that.apiName,_that.displayName,_that.description,_that.icon,_that.coloredIcon,_that.isAchieved,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String apiName,  String displayName,  String? description,  String? icon,  String? coloredIcon,  bool isAchieved,  DateTime? achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrophyModel() when $default != null:
return $default(_that.apiName,_that.displayName,_that.description,_that.icon,_that.coloredIcon,_that.isAchieved,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrophyModel extends TrophyModel {
  const _TrophyModel({required this.apiName, required this.displayName, this.description, this.icon, this.coloredIcon, this.isAchieved = false, this.achievedAt}): super._();
  factory _TrophyModel.fromJson(Map<String, dynamic> json) => _$TrophyModelFromJson(json);

@override final  String apiName;
@override final  String displayName;
@override final  String? description;
@override final  String? icon;
@override final  String? coloredIcon;
@override@JsonKey() final  bool isAchieved;
@override final  DateTime? achievedAt;

/// Create a copy of TrophyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrophyModelCopyWith<_TrophyModel> get copyWith => __$TrophyModelCopyWithImpl<_TrophyModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrophyModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrophyModel&&(identical(other.apiName, apiName) || other.apiName == apiName)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.coloredIcon, coloredIcon) || other.coloredIcon == coloredIcon)&&(identical(other.isAchieved, isAchieved) || other.isAchieved == isAchieved)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,apiName,displayName,description,icon,coloredIcon,isAchieved,achievedAt);

@override
String toString() {
  return 'TrophyModel(apiName: $apiName, displayName: $displayName, description: $description, icon: $icon, coloredIcon: $coloredIcon, isAchieved: $isAchieved, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$TrophyModelCopyWith<$Res> implements $TrophyModelCopyWith<$Res> {
  factory _$TrophyModelCopyWith(_TrophyModel value, $Res Function(_TrophyModel) _then) = __$TrophyModelCopyWithImpl;
@override @useResult
$Res call({
 String apiName, String displayName, String? description, String? icon, String? coloredIcon, bool isAchieved, DateTime? achievedAt
});




}
/// @nodoc
class __$TrophyModelCopyWithImpl<$Res>
    implements _$TrophyModelCopyWith<$Res> {
  __$TrophyModelCopyWithImpl(this._self, this._then);

  final _TrophyModel _self;
  final $Res Function(_TrophyModel) _then;

/// Create a copy of TrophyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? apiName = null,Object? displayName = null,Object? description = freezed,Object? icon = freezed,Object? coloredIcon = freezed,Object? isAchieved = null,Object? achievedAt = freezed,}) {
  return _then(_TrophyModel(
apiName: null == apiName ? _self.apiName : apiName // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,coloredIcon: freezed == coloredIcon ? _self.coloredIcon : coloredIcon // ignore: cast_nullable_to_non_nullable
as String?,isAchieved: null == isAchieved ? _self.isAchieved : isAchieved // ignore: cast_nullable_to_non_nullable
as bool,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
