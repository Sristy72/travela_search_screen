class SearchMetaModel {
  final int totalCount;
  final Map<String, dynamic>? filterMeta;
  final Map<String, dynamic>? pagination;

  SearchMetaModel({
    required this.totalCount,
    this.filterMeta,
    this.pagination,
  });

  factory SearchMetaModel.fromJson(Map<String, dynamic> json) {
    return SearchMetaModel(
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
      filterMeta: json['filter_meta'] as Map<String, dynamic>?,
      pagination: json['pagination'] as Map<String, dynamic>?,
    );
  }
}
