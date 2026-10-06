import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/mediathek_item.dart';
import '../services/mediathek_service.dart';
import '../widgets/category_section_row.dart';
import '../widgets/channel_filter_chips.dart';
import '../widgets/compact_video_card.dart';
import '../widgets/main_category_bar.dart';
import '../widgets/subcategory_chips.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MediathekService _service = MediathekService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Aktive Filter
  MediathekCategory _selectedCategory = MediathekCategory.categories.first; // Übersicht
  String _selectedSubcategory = 'Alle';
  String _selectedChannel = 'Alle';
  String _currentQuery = '';

  // Datenzustand
  List<MediathekItem> _itemList = [];
  Map<MediathekCategory, List<MediathekItem>> _categorySections = {};

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';

  int _currentOffset = 0;
  final int _pageSize = 30;
  bool _hasMore = true;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoadingMore &&
          _hasMore &&
          !_isLoading &&
          _selectedCategory.id != 'all') {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool reset = true}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _currentOffset = 0;
        _itemList.clear();
        _categorySections.clear();
        _hasMore = true;
      });
    }

    try {
      // 1. Übersicht (Startseite): Themenblöcke wie ARD/ZDF Homepage
      if (_selectedCategory.id == 'all' && _currentQuery.trim().isEmpty) {
        final sections = await _service.fetchCategorySections(
          channel: _selectedChannel,
        );

        if (mounted) {
          setState(() {
            _categorySections = sections;
            _isLoading = false;
          });
        }
      } else {
        // 2. Spezifische Kategorie / Unterkategorie / Suche
        List<MediathekItem> items = [];

        if (_currentQuery.trim().isNotEmpty) {
          items = await _service.fetchItems(
            query: _currentQuery,
            channel: _selectedChannel,
            size: _pageSize,
            offset: _currentOffset,
          );
        } else {
          items = await _service.fetchCategoryItems(
            category: _selectedCategory,
            subcategory: _selectedSubcategory,
            channel: _selectedChannel,
            size: _pageSize,
          );
        }

        if (mounted) {
          setState(() {
            if (reset) {
              _itemList = items;
            } else {
              _itemList.addAll(items);
            }
            _isLoading = false;
            _isLoadingMore = false;
            _hasMore = items.length >= _pageSize;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentOffset += _pageSize;
    });

    await _fetchData(reset: false);
  }

  void _onCategorySelected(MediathekCategory category) {
    if (_selectedCategory.id != category.id) {
      setState(() {
        _selectedCategory = category;
        _selectedSubcategory = category.subcategories.isNotEmpty
            ? category.subcategories.first
            : 'Alle';
      });
      _fetchData(reset: true);
    }
  }

  void _onSubcategorySelected(String subcategory) {
    if (_selectedSubcategory != subcategory) {
      setState(() {
        _selectedSubcategory = subcategory;
      });
      _fetchData(reset: true);
    }
  }

  void _onChannelSelected(String channel) {
    if (_selectedChannel != channel) {
      setState(() {
        _selectedChannel = channel;
      });
      _fetchData(reset: true);
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (_currentQuery != query) {
        _currentQuery = query;
        _fetchData(reset: true);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    if (_currentQuery.isNotEmpty) {
      _currentQuery = '';
      _fetchData(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tv_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'MediathekView',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Aktualisieren',
            onPressed: () => _fetchData(reset: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Suchleiste
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Sendungen, Themen, Tagesschau, Serien suchen...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. Hauptkategorien-Leiste
          MainCategoryBar(
            selectedCategory: _selectedCategory,
            onCategorySelected: _onCategorySelected,
          ),

          const SizedBox(height: 6),

          // 3. Unterkategorien Chips
          if (_selectedCategory.subcategories.isNotEmpty &&
              _currentQuery.isEmpty)
            SubcategoryChips(
              subcategories: _selectedCategory.subcategories,
              selectedSubcategory: _selectedSubcategory,
              onSubcategorySelected: _onSubcategorySelected,
            ),

          // 4. Sender Filter Chips
          ChannelFilterChips(
            channels: MediathekService.availableChannels,
            selectedChannel: _selectedChannel,
            onChannelSelected: _onChannelSelected,
          ),

          const SizedBox(height: 8),

          // Haupt-Content Bereich
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 16),
            Text('Lade Mediathek-Kategorien...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(_errorMessage,
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 15),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _fetchData(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // A) Übersicht-Ansicht: Themen-Reihen wie ARD/ZDF Homepage
    if (_selectedCategory.id == 'all' && _currentQuery.isEmpty) {
      if (_categorySections.isEmpty) {
        return const Center(
          child: Text('Keine Kategorien verfügbar.',
              style: TextStyle(color: Colors.grey)),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _fetchData(reset: true),
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: _categorySections.entries.map((entry) {
            return CategorySectionRow(
              category: entry.key,
              items: entry.value,
              onSeeAllPressed: () => _onCategorySelected(entry.key),
            );
          }).toList(),
        ),
      );
    }

    // B) Raster-Grid mit kompakten Karten für JEDE Seite (Nachrichten, Filme, Serien, Suche etc.)
    if (_itemList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _currentQuery.isNotEmpty
                  ? 'Keine Ergebnisse für "$_currentQuery" gefunden.'
                  : 'Keine Sendungen in "${_selectedCategory.title}" gefunden.',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchData(reset: true),
      color: Colors.blueAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      child: GridView.extent(
        controller: _scrollController,
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: _itemList.map((item) {
          return CompactVideoCard(
            item: item,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(item: item),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
