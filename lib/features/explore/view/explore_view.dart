import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trophies_app_tracker/core/providers/state_provider.dart';
import 'package:trophies_app_tracker/features/explore/viewmodel/explore_view_model.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final SearchController _searchController = SearchController();
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<MainScreen>(activeScreenProvider, (previous, next) {
        if (next == MainScreen.explore) {
          _focusNode.requestFocus();
        } else {
          _hasFocus = false;
          _focusNode.unfocus();
          _searchController.clear();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(jsonDataProvider);
    final searchResults = ref.watch(suggestionBuilderProvider);
    return asyncData.when(
      data: (allGames) {
        return Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SearchBar(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12.0),
                    ),
                  ),
                  controller: _searchController,
                  focusNode: _focusNode,
                  hintText: 'Search games...',
                  onTap: () {
                    _hasFocus = true;
                    ref.invalidate(suggestionBuilderProvider);
                    ref
                        .read(suggestionBuilderProvider.notifier)
                        .searchByValue('', allGames);
                  },
                  onChanged: (query) {
                    _hasFocus = true;
                    ref
                        .read(suggestionBuilderProvider.notifier)
                        .searchByValue(query, allGames);
                  },
                  trailing: [
                    if (_hasFocus)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _focusNode.unfocus();
                          _searchController.clear();
                        },
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _hasFocus
                  ? ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final game = searchResults[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            tileColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                            title: Text(game.name),
                            subtitle: Text("AppID: ${game.appid}"),
                            onTap: () async {
                              final alreadyExist = await ref
                                  .read(suggestionBuilderProvider.notifier)
                                  .checkIfAlreadyExist(game.appid);
                              if (alreadyExist) {
                                if (!context.mounted) return;
                                context.pushNamed(
                                  'gameDetailsOffline',
                                  pathParameters: {
                                    'appId': game.appid.toString(),
                                  },
                                  extra: {
                                    'heroTag': 'nohero-${game.appid}',
                                    'disableHero': true,
                                  },
                                );
                                return;
                              }
                              if (!context.mounted) return;
                              context.pushNamed(
                                'gameDetails',
                                pathParameters: {
                                  'appId': game.appid.toString(),
                                },
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            "Search any game by name or AppID",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text("Errore: $error")),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
