class MediathekItem {
  final String id;
  final String channel;
  final String topic;
  final String title;
  final String description;
  final int timestamp;
  final int duration;
  final String urlVideo;
  final String urlVideoHd;
  final String urlVideoLow;
  final String urlVideoPreview;
  final String urlWebsite;

  MediathekItem({
    required this.id,
    required this.channel,
    required this.topic,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.duration,
    required this.urlVideo,
    required this.urlVideoHd,
    required this.urlVideoLow,
    required this.urlVideoPreview,
    required this.urlWebsite,
  });

  factory MediathekItem.fromJson(Map<String, dynamic> json) {
    return MediathekItem(
      id: json['id']?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'Unbekannt',
      topic: json['topic']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Kein Titel',
      description: json['description']?.toString() ?? '',
      timestamp: json['timestamp'] is int
          ? json['timestamp']
          : int.tryParse(json['timestamp']?.toString() ?? '0') ?? 0,
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      urlVideo: json['url_video']?.toString() ?? '',
      urlVideoHd: json['url_video_hd']?.toString() ?? '',
      urlVideoLow: json['url_video_low']?.toString() ?? '',
      urlVideoPreview: json['url_video_preview']?.toString() ?? '',
      urlWebsite: json['url_website']?.toString() ?? '',
    );
  }

  /// Gibt die beste verfügbare Video-URL zurück (bevorzugt HD, sonst Standard, sonst Low)
  String get bestVideoUrl {
    if (urlVideoHd.isNotEmpty) return urlVideoHd;
    if (urlVideo.isNotEmpty) return urlVideo;
    if (urlVideoLow.isNotEmpty) return urlVideoLow;
    return '';
  }

  /// Gibt die Beschreibung zurück oder erzeugt einen passenden Ausweichtext,
  /// falls der Fernsehsender in der API keine Beschreibung mitgeliefert hat.
  String get displayDescription {
    final cleanDesc = description.trim();
    if (cleanDesc.isNotEmpty) {
      return cleanDesc;
    }
    final cleanTopic = topic.trim();
    if (cleanTopic.isNotEmpty) {
      return 'Beitrag aus der Sendereihe "$cleanTopic".';
    }
    return 'Keine zusätzliche Beschreibung vom Sender bereitgestellt.';
  }

  /// Formatierte Dauer (z.B. "15 Min." oder "1 Std. 12 Min.")
  String get formattedDuration {
    if (duration <= 0) return '';
    final minutes = duration ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '$hours Std. ${remainingMinutes > 0 ? '$remainingMinutes Min.' : ''}';
    }
    return '$minutes Min.';
  }

  /// Formatiertes Sendedatum (z.B. "14.05.2024, 20:00 Uhr")
  String get formattedDate {
    if (timestamp <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day.$month.$year, $hour:$minute Uhr';
  }
}
