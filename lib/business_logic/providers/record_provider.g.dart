// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseServiceHash() => r'766f41a8fb8947216fae68bbc31fa62d037f6899';

/// See also [databaseService].
@ProviderFor(databaseService)
final databaseServiceProvider = AutoDisposeProvider<DatabaseService>.internal(
  databaseService,
  name: r'databaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseServiceRef = AutoDisposeProviderRef<DatabaseService>;
String _$recordsNotifierHash() => r'542ba8b26183156f3884fe16c25e03bccffa6462';

/// See also [RecordsNotifier].
@ProviderFor(RecordsNotifier)
final recordsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RecordsNotifier, List<Record>>.internal(
  RecordsNotifier.new,
  name: r'recordsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecordsNotifier = AutoDisposeAsyncNotifier<List<Record>>;
String _$recordNotifierHash() => r'21a16b091db52d0d20d5e848211f3c5e1e8c9b3f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$RecordNotifier
    extends BuildlessAutoDisposeAsyncNotifier<Record?> {
  late final String id;

  FutureOr<Record?> build(
    String id,
  );
}

/// See also [RecordNotifier].
@ProviderFor(RecordNotifier)
const recordNotifierProvider = RecordNotifierFamily();

/// See also [RecordNotifier].
class RecordNotifierFamily extends Family<AsyncValue<Record?>> {
  /// See also [RecordNotifier].
  const RecordNotifierFamily();

  /// See also [RecordNotifier].
  RecordNotifierProvider call(
    String id,
  ) {
    return RecordNotifierProvider(
      id,
    );
  }

  @override
  RecordNotifierProvider getProviderOverride(
    covariant RecordNotifierProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recordNotifierProvider';
}

/// See also [RecordNotifier].
class RecordNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<RecordNotifier, Record?> {
  /// See also [RecordNotifier].
  RecordNotifierProvider(
    String id,
  ) : this._internal(
          () => RecordNotifier()..id = id,
          from: recordNotifierProvider,
          name: r'recordNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recordNotifierHash,
          dependencies: RecordNotifierFamily._dependencies,
          allTransitiveDependencies:
              RecordNotifierFamily._allTransitiveDependencies,
          id: id,
        );

  RecordNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<Record?> runNotifierBuild(
    covariant RecordNotifier notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(RecordNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecordNotifierProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<RecordNotifier, Record?>
      createElement() {
    return _RecordNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordNotifierProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecordNotifierRef on AutoDisposeAsyncNotifierProviderRef<Record?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _RecordNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RecordNotifier, Record?>
    with RecordNotifierRef {
  _RecordNotifierProviderElement(super.provider);

  @override
  String get id => (origin as RecordNotifierProvider).id;
}

String _$tagsNotifierHash() => r'7df0d7bfd8806882e004bc259a7180c4ddd0a7db';

/// See also [TagsNotifier].
@ProviderFor(TagsNotifier)
final tagsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TagsNotifier, List<String>>.internal(
  TagsNotifier.new,
  name: r'tagsNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tagsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TagsNotifier = AutoDisposeAsyncNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
