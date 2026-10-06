import 'package:flutter/material.dart';

class MediathekCategory {
  final String id;
  final String title;
  final IconData icon;
  final List<String> searchTerms;
  final List<String> subcategories;

  const MediathekCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.searchTerms,
    required this.subcategories,
  });

  static const List<MediathekCategory> categories = [
    MediathekCategory(
      id: 'all',
      title: 'Übersicht',
      icon: Icons.grid_view_rounded,
      searchTerms: [],
      subcategories: [],
    ),
    MediathekCategory(
      id: 'news',
      title: 'Nachrichten & Tagesschau',
      icon: Icons.newspaper_rounded,
      searchTerms: ['tagesschau', 'heute', 'nachrichten', 'br24', 'aktuell'],
      subcategories: ['Alle Nachrichten', 'Tagesschau', 'heute journal', 'BR24', 'logo!'],
    ),
    MediathekCategory(
      id: 'movies',
      title: 'Filme',
      icon: Icons.movie_rounded,
      searchTerms: ['film', 'spielfilm', 'tatort', 'krimi', 'kino'],
      subcategories: ['Alle Filme', 'Tatort', 'Spielfilme', 'Krimis', 'Komödien'],
    ),
    MediathekCategory(
      id: 'series',
      title: 'Serien',
      icon: Icons.tv_rounded,
      searchTerms: ['serie', 'sturm der liebe', 'soko', 'in aller freundschaft', 'rote rosen'],
      subcategories: ['Alle Serien', 'Sturm der Liebe', 'SOKO', 'In aller Freundschaft', 'Rote Rosen'],
    ),
    MediathekCategory(
      id: 'doku',
      title: 'Dokus & Wissen',
      icon: Icons.explore_rounded,
      searchTerms: ['doku', 'dokumentation', 'terra x', 'wiso', 'reportage', 'geschichte'],
      subcategories: ['Alle Dokus', 'Terra X', 'Reportagen', 'Geschichte', 'Natur & Umwelt'],
    ),
    MediathekCategory(
      id: 'entertainment',
      title: 'Show & Satire',
      icon: Icons.theater_comedy_rounded,
      searchTerms: ['show', 'heute-show', 'extra 3', 'satire', 'talkshow', 'magazin'],
      subcategories: ['Alle Shows', 'heute-show', 'extra 3', 'Talkshows', 'Kabarett'],
    ),
    MediathekCategory(
      id: 'sport',
      title: 'Sport',
      icon: Icons.sports_soccer_rounded,
      searchTerms: ['sport', 'sportschau', 'sportstudio', 'fußball', 'bundesliga'],
      subcategories: ['Alle Sportarten', 'Sportschau', 'Sportstudio', 'Fußball'],
    ),
    MediathekCategory(
      id: 'children',
      title: 'Kinder & Familie',
      icon: Icons.child_care_rounded,
      searchTerms: ['kinder', 'maus', 'kika', 'löwenzahn', 'animation', 'tivi'],
      subcategories: ['Alle Kinderinhalte', 'Die Sendung mit der Maus', 'Löwenzahn', 'KiKa'],
    ),
  ];
}
