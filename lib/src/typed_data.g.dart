// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypedData _$TypedDataFromJson(Map<String, dynamic> json) {
  return TypedData(
    types: (json['types'] as Map<String, dynamic>).map((k, e) => MapEntry(k, (e as List).map((e) => TypedDataField.fromJson(e as Map<String, dynamic>)).toList())),
    primaryType: json['primaryType'] as String,
    domain: json['domain'] == null ? null : EIP712Domain.fromJson(json['domain'] as Map<String, dynamic>),
    message: json['message'] as Map<String, dynamic>
  );
}

Map<String, dynamic> _$TypedDataToJson(TypedData instance) => <String, dynamic>{
  'types': instance.types,
  'primaryType': instance.primaryType,
  'domain': instance.domain,
  'message': instance.message
};

TypedDataField _$TypedDataFieldFromJson(Map<String, dynamic> json) {
  return TypedDataField(name: json['name'] as String, type: json['type'] as String);
}

Map<String, dynamic> _$TypedDataFieldToJson(TypedDataField instance) => <String, dynamic>{'name': instance.name, 'type': instance.type};

EIP712Domain _$EIP712DomainFromJson(Map<String, dynamic> json) {
  return EIP712Domain(
    name: json['name'] as String,
    version: json['version'] as String,
    chainId: json['chainId'] as int,
    verifyingContract: json['verifyingContract'] as String
  );
}

Map<String, dynamic> _$EIP712DomainToJson(EIP712Domain instance) =>
  <String, dynamic>{
    'name': instance.name,
    'version': instance.version,
    'chainId': instance.chainId,
    'verifyingContract': instance.verifyingContract
  };
