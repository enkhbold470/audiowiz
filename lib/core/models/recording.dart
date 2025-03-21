import 'package:uuid/uuid.dart';

class Recording {
  final int? id;
  final String uuid;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final int durationInSeconds;
  
  String? transcription;
  String? summary;
  bool isProcessed;
  bool isFavorite;
  String? supabaseId;

  Recording({
    this.id,
    required this.title,
    required this.filePath,
    required this.durationInSeconds,
    String? uuid,
    this.transcription,
    this.summary,
    this.isProcessed = false,
    this.isFavorite = false,
    this.supabaseId,
  }) : 
    this.uuid = uuid ?? const Uuid().v4(),
    this.createdAt = DateTime.now();
    
  // Create a copy of the recording with updated values
  Recording copyWith({
    int? id,
    String? title,
    String? filePath,
    int? durationInSeconds,
    String? transcription,
    String? summary,
    bool? isProcessed,
    bool? isFavorite,
    String? supabaseId,
  }) {
    return Recording(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      uuid: this.uuid,
      transcription: transcription ?? this.transcription,
      summary: summary ?? this.summary,
      isProcessed: isProcessed ?? this.isProcessed,
      isFavorite: isFavorite ?? this.isFavorite,
      supabaseId: supabaseId ?? this.supabaseId,
    );
  }
  
  // Convert recording to a map for storing in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'durationInSeconds': durationInSeconds,
      'transcription': transcription,
      'summary': summary,
      'isProcessed': isProcessed ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'supabaseId': supabaseId,
    };
  }
  
  // Create a recording from a map from SQLite
  factory Recording.fromMap(Map<String, dynamic> map) {
    return Recording(
      id: map['id'],
      title: map['title'],
      filePath: map['filePath'],
      durationInSeconds: map['durationInSeconds'],
      uuid: map['uuid'],
      transcription: map['transcription'],
      summary: map['summary'],
      isProcessed: map['isProcessed'] == 1,
      isFavorite: map['isFavorite'] == 1,
      supabaseId: map['supabaseId'],
    );
  }
} 