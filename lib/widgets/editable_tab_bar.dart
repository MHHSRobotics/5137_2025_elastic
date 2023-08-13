import 'package:contextmenu/contextmenu.dart';
import 'package:elastic_dashboard/services/globals.dart';
import 'package:elastic_dashboard/widgets/dashboard_grid.dart';
import 'package:elastic_dashboard/widgets/dialog_widgets/dialog_text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transitioned_indexed_stack/transitioned_indexed_stack.dart';

class TabData {
  String name;

  TabData({required this.name});
}

class EditableTabBar extends StatelessWidget {
  final List<DashboardGrid> tabViews;
  final List<TabData> tabData;

  final Function(TabData tab, DashboardGrid grid) onTabCreate;
  final Function(TabData tab, DashboardGrid grid) onTabDestroy;
  final Function(int index, TabData newData) onTabRename;
  final Function(int index) onTabChanged;

  final int currentIndex;

  const EditableTabBar({
    super.key,
    required this.currentIndex,
    required this.tabData,
    required this.tabViews,
    required this.onTabCreate,
    required this.onTabDestroy,
    required this.onTabRename,
    required this.onTabChanged,
  });

  void renameTab(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Tab'),
          content: DialogTextInput(
            onSubmit: (value) {
              tabData[index].name = value;
              onTabRename.call(index, tabData[index]);
            },
            initialText: tabData[index].name,
            label: 'Name',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void createTab() {
    String tabName = 'Tab ${tabData.length + 1}';
    TabData data = TabData(name: tabName);
    DashboardGrid grid = DashboardGrid(key: GlobalKey());

    onTabCreate.call(data, grid);
  }

  void closeTab(int index) {
    if (tabData.length == 1) {
      return;
    }

    TabData data = tabData[index];
    DashboardGrid grid = tabViews[index];

    tabData.removeAt(index);
    tabViews.removeAt(index);

    // if (currentIndex > 0) {
    //   currentIndex--;
    // }

    onTabDestroy.call(data, grid);
  }

  void showTabCloseConfirmation(
      BuildContext context, String tabName, Function() onClose) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClose.call();
                },
                child: const Text('OK')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
          ],
          content: Text('Do you want to close the tab "$tabName"?'),
          title: const Text('Confirm Tab Close'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Tab bar
        Container(
          width: double.infinity,
          height: 36,
          color: theme.colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: tabData.length,
                  itemBuilder: (context, index) {
                    return ContextMenuArea(
                      builder: (context) => [
                        ListTile(
                          enabled: false,
                          dense: true,
                          visualDensity: const VisualDensity(
                              horizontal: 0.0, vertical: -4.0),
                          title: Center(child: Text(tabData[index].name)),
                        ),
                        ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(
                              horizontal: 0.0, vertical: -4.0),
                          leading: const Icon(Icons.drive_file_rename_outline_outlined),
                          title: const Text('Rename'),
                          onTap: () {
                            Navigator.of(context).pop();
                            renameTab(context, index);
                          },
                        ),
                        ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(
                              horizontal: 0.0, vertical: -4.0),
                          leading: const Icon(Icons.close),
                          title: const Text('Close'),
                          onTap: () {
                            Navigator.of(context).pop();
                            showTabCloseConfirmation(
                                context, tabData[index].name, () {
                              closeTab(index);
                            });
                          },
                        ),
                      ],
                      child: GestureDetector(
                        onTap: () {
                          onTabChanged.call(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutExpo,
                          margin: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 5.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: (currentIndex == index)
                                ? theme.colorScheme.onPrimaryContainer
                                : Colors.transparent,
                            borderRadius: (currentIndex == index)
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  )
                                : BorderRadius.zero,
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                Text(
                                  tabData[index].name,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: (currentIndex == index)
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    showTabCloseConfirmation(
                                        context, tabData[index].name, () {
                                      closeTab(index);
                                    });
                                  },
                                  padding: const EdgeInsets.all(0.0),
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(
                                    minWidth: 15.0,
                                    minHeight: 15.0,
                                  ),
                                  iconSize: 14,
                                  color: (currentIndex == index)
                                      ? theme.colorScheme.primaryContainer
                                      : theme.colorScheme.onPrimaryContainer,
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  createTab();
                },
                alignment: Alignment.center,
                icon: const Icon(Icons.add),
              )
            ],
          ),
        ),
        // Dashboard grid area
        Flexible(
          child: Stack(
            children: [
              Visibility(
                visible: Globals.showGrid,
                child: GridPaper(
                  color: const Color.fromARGB(50, 195, 232, 243),
                  interval: Globals.gridSize.toDouble(),
                  divisions: 1,
                  subdivisions: 1,
                  child: Container(),
                ),
              ),
              FadeIndexedStack(
                beginOpacity: 0.0,
                endOpacity: 1.0,
                index: currentIndex,
                children: [
                  for (DashboardGrid grid in tabViews)
                    ChangeNotifierProvider(
                      create: (context) => DashboardGridModel(),
                      child: grid,
                    ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
