import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/mediathek_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediathekItem item;

  const VideoPlayerScreen({super.key, required this.item});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isDescriptionExpanded = false;
  String _errorMessage = '';
  late String _currentVideoUrl;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _currentVideoUrl = widget.item.bestVideoUrl;
    _initializePlayer(_currentVideoUrl);
  }

  void _initializePlayer(String url) {
    setState(() {
      _isInitialized = false;
      _errorMessage = '';
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
          _startHideControlsTimer();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Fehler beim Laden des Videos: $error';
          });
        }
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _hideControlsTimer?.cancel();
        _showControls = true;
      } else {
        _controller.play();
        _startHideControlsTimer();
      }
    });
  }

  void _seekRelative(int seconds) {
    final currentPosition = _controller.value.position;
    final targetPosition = currentPosition + Duration(seconds: seconds);
    _controller.seekTo(targetPosition);
    _startHideControlsTimer();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1F1F1F),
              title: Text(
                widget.item.title,
                style: const TextStyle(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (widget.item.urlVideoHd.isNotEmpty &&
                    widget.item.urlVideoLow.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Qualität auswählen',
                    onSelected: (url) {
                      if (url != _currentVideoUrl) {
                        _currentVideoUrl = url;
                        _controller.dispose();
                        _initializePlayer(url);
                      }
                    },
                    itemBuilder: (context) => [
                      if (widget.item.urlVideoHd.isNotEmpty)
                        PopupMenuItem(
                          value: widget.item.urlVideoHd,
                          child: Row(
                            children: [
                              if (_currentVideoUrl == widget.item.urlVideoHd)
                                const Icon(Icons.check, size: 18),
                              const SizedBox(width: 8),
                              const Text('HD Qualität'),
                            ],
                          ),
                        ),
                      if (widget.item.urlVideo.isNotEmpty)
                        PopupMenuItem(
                          value: widget.item.urlVideo,
                          child: Row(
                            children: [
                              if (_currentVideoUrl == widget.item.urlVideo)
                                const Icon(Icons.check, size: 18),
                              const SizedBox(width: 8),
                              const Text('Standard Qualität'),
                            ],
                          ),
                        ),
                      if (widget.item.urlVideoLow.isNotEmpty)
                        PopupMenuItem(
                          value: widget.item.urlVideoLow,
                          child: Row(
                            children: [
                              if (_currentVideoUrl == widget.item.urlVideoLow)
                                const Icon(Icons.check, size: 18),
                              const SizedBox(width: 8),
                              const Text('Niedrige Qualität'),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
      body: SafeArea(
        top: !_isFullScreen,
        bottom: !_isFullScreen,
        child: Column(
          children: [
            // Video-Player Bereich
            Expanded(
              child: Center(
                child: _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _isInitialized
                        ? GestureDetector(
                            onTap: _toggleControls,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                                if (_showControls) _buildControlsOverlay(),
                              ],
                            ),
                          )
                        : const CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),

            // Details & Expandable Description (nur im Hochformat)
            if (!_isFullScreen) ...[
              Container(
                color: const Color(0xFF141414),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.item.channel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (widget.item.topic.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.item.topic,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Expandable Description Box
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.displayDescription,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                                maxLines: _isDescriptionExpanded ? null : 3,
                                overflow: _isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _isDescriptionExpanded
                                        ? 'Weniger anzeigen ▲'
                                        : 'Beschreibung erweitern ▼',
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            widget.item.formattedDate,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    final position = _controller.value.position;
    final duration = _controller.value.duration;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_isFullScreen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _toggleFullScreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 42,
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                onPressed: () => _seekRelative(-10),
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 64,
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: Colors.white,
                ),
                onPressed: _togglePlayPause,
              ),
              const SizedBox(width: 24),
              IconButton(
                iconSize: 42,
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                onPressed: () => _seekRelative(10),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.blueAccent,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white10,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _toggleFullScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _initializePlayer(_currentVideoUrl),
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}
