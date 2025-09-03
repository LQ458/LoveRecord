// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$aiServiceHash() => r'384446894a4241d6e77bd653c31e7dc8447a05ad';

/// See also [aiService].
@ProviderFor(aiService)
final aiServiceProvider = AutoDisposeProvider<AIService?>.internal(
  aiService,
  name: r'aiServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$aiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiServiceRef = AutoDisposeProviderRef<AIService?>;
String _$aIServiceNotifierHash() => r'37e4b9bed6fe0b17911a91ff6ab0717d7819c230';

/// See also [AIServiceNotifier].
@ProviderFor(AIServiceNotifier)
final aIServiceNotifierProvider =
    AutoDisposeNotifierProvider<AIServiceNotifier, AIService?>.internal(
  AIServiceNotifier.new,
  name: r'aIServiceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aIServiceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AIServiceNotifier = AutoDisposeNotifier<AIService?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
