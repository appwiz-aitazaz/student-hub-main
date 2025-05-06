import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_hub/widgets/home_button.dart';
import 'dart:convert';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/screen_header.dart';
import '../../widgets/app_drawer.dart';
import 'dart:math' as math;

class DocumentSubmissionScreen extends StatefulWidget {
  @override
  _DocumentSubmissionScreenState createState() => _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState extends State<DocumentSubmissionScreen> {
  List<DocumentItem> documents = [];
  List<FolderItem> folders = [];
  bool isLoading = false;
  String currentFolder = 'Root';
  List<String> folderPath = ['Root'];
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/profile');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }
  
   // Add this as a class variable
  List<DocumentItem> allDocuments = [];
  List<FolderItem> allFolders = [];

  Future<void> _loadSavedData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load folders
      final foldersJson = prefs.getString('folders') ?? '[]';
      final List<dynamic> foldersData = jsonDecode(foldersJson);
      
      // Load all folders
      allFolders = foldersData.map((folderData) {
        return FolderItem(
          name: folderData['name'],
          dateCreated: DateTime.parse(folderData['dateCreated']),
          parentFolder: folderData['parentFolder'],
        );
      }).toList();
      
      // Load documents
      final documentsJson = prefs.getString('documents') ?? '[]';
      final List<dynamic> documentsData = jsonDecode(documentsJson);
      
      allDocuments = documentsData.map((docData) {
        return DocumentItem(
          name: docData['name'],
          size: docData['size'],
          dateAdded: DateTime.parse(docData['dateAdded']),
          type: DocumentType.values[docData['type']],
          path: docData['path'],
          folder: docData['folder'],
        );
      }).toList();
      
      // Filter for current folder view
      _filterItemsForCurrentFolder();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Updated filter method
  void _filterItemsForCurrentFolder() {
    // Filter folders for the current folder
    folders = allFolders.where((folder) => 
      folder.parentFolder == currentFolder
    ).toList();
    
    // Filter documents for the current folder
    documents = allDocuments.where((doc) => 
      doc.folder == currentFolder
    ).toList();
  }

  void _filterDocumentsForCurrentFolder() {
    _filterItemsForCurrentFolder();
  }

 Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all folders
      final List<Map<String, dynamic>> foldersData = allFolders.map((folder) {
        return {
          'name': folder.name,
          'dateCreated': folder.dateCreated.toIso8601String(),
          'parentFolder': folder.parentFolder,
        };
      }).toList();
      
      await prefs.setString('folders', jsonEncode(foldersData));
      
      // Save all documents
      final List<Map<String, dynamic>> documentsData = allDocuments.map((doc) {
        return {
          'name': doc.name,
          'size': doc.size,
          'dateAdded': doc.dateAdded.toIso8601String(),
          'type': doc.type.index,
          'path': doc.path ?? '',
          'folder': doc.folder,
        };
      }).toList();
      
      await prefs.setString('documents', jsonEncode(documentsData));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      // For Android 13+ (SDK 33+), we need to request specific permissions
      if (Platform.isAndroid) {
        // Request the specific photo and video permissions for Android 13+
        final photosStatus = await Permission.photos.request();
        final videosStatus = await Permission.videos.request();
        final audioStatus = await Permission.audio.request();
        final storageStatus = await Permission.storage.request();
        
        // Check if any permission is granted
        bool hasPermission = photosStatus.isGranted || 
                            videosStatus.isGranted || 
                            audioStatus.isGranted || 
                            storageStatus.isGranted;
        
        if (!hasPermission) {
          // Show custom file picker that doesn't require permissions
          final result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.any,
            withData: true, // This ensures we get the file bytes
          );
          
          if (result != null) {
            _processPickedFiles(result);
          }
          return;
        }
      }
      
      // Standard file picking
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );

      if (result != null) {
        _processPickedFiles(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _processPickedFiles(FilePickerResult result) async {
    try {
      List<DocumentItem> newDocuments = [];
      
      for (var file in result.files) {
        String? filePath;
        
        // Always save to app directory to avoid permission issues
        if (file.bytes != null) {
          filePath = await _saveFileToAppDirectory(file);
        } else if (file.path != null) {
          // If we have a path but no bytes, try to copy the file
          filePath = await _copyFileToAppDirectory(file);
        }
        
        if (filePath != null) {
          newDocuments.add(
            DocumentItem(
              name: file.name,
              size: _formatBytes(file.size),
              dateAdded: DateTime.now(),
              type: _getDocumentType(file.extension ?? ''),
              path: filePath,
              folder: currentFolder,
            ),
          );
        }
      }
      
      if (newDocuments.isNotEmpty) {
        setState(() {
          // Add to both all documents and current documents
          allDocuments.addAll(newDocuments);
          documents.addAll(newDocuments);
        });
        
        await _saveData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${newDocuments.length} file(s) uploaded successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing files: $e')),
      );
    }
  }

  Future<String?> _copyFileToAppDirectory(PlatformFile file) async {
    try {
      if (file.path == null) return null;
      
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${file.name}';
      
      final sourceFile = File(file.path!);
      final newFile = File(newPath);
      
      // Copy the file to app directory
      await sourceFile.copy(newPath);
      
      return newPath;
    } catch (e) {
      print('Error copying file: $e');
      return null;
    }
  }

  Future<String?> _saveFileToAppDirectory(PlatformFile file) async {
    try {
      if (file.bytes == null) return null;
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${file.name}';
      
      final newFile = File(filePath);
      await newFile.writeAsBytes(file.bytes!);
      
      return filePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
      return null;
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Text('Permission Required', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This app needs storage permission to manage your files.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Please grant permission in app settings to continue.',
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.settings, size: 18),
            label: Text('Open Settings', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
          ),
        ],
      ),
    );
  }
  
  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  DocumentType _getDocumentType(String extension) {
    extension = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
      return DocumentType.image;
    } else if (['pdf'].contains(extension)) {
      return DocumentType.pdf;
    } else if (['doc', 'docx', 'txt', 'rtf'].contains(extension)) {
      return DocumentType.document;
    } else if (['xls', 'xlsx', 'csv'].contains(extension)) {
      return DocumentType.spreadsheet;
    } else if (['ppt', 'pptx'].contains(extension)) {
      return DocumentType.presentation;
    } else {
      return DocumentType.other;
    }
  }

  Future<void> _createFolder() async {
    final TextEditingController folderNameController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.create_new_folder, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text('Create New Folder', style: TextStyle(fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a name for your new folder:',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              TextField(
                controller: folderNameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Folder name',
                  prefixIcon: Icon(Icons.folder, color: Colors.amber),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.check, size: 18),
              label: Text('Create', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  final newFolder = FolderItem(
                    name: folderNameController.text,
                    dateCreated: DateTime.now(),
                    parentFolder: currentFolder,
                  );
                  
                  setState(() {
                    // Add to both all folders and current folders
                    allFolders.add(newFolder);
                    folders.add(newFolder);
                  });
                  
                  await _saveData();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Folder "${folderNameController.text}" created'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToFolder(FolderItem folder) async {
    setState(() {
      currentFolder = folder.name;
      folderPath.add(folder.name);
      isLoading = true;
    });
    
    await _loadSavedData();
  }

  void _navigateUp() async {
    if (folderPath.length > 1) {
      setState(() {
        folderPath.removeLast();
        currentFolder = folderPath.last;
        isLoading = true;
      });
      
      await _loadSavedData();
    }
  }

  Future<void> _viewDocument(DocumentItem document) async {
    if (document.path != null && document.path!.isNotEmpty) {
      try {
        final result = await OpenFile.open(document.path!);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening file: ${result.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File path not available')),
      );
    }
  }

  Future<void> _downloadDocument(DocumentItem document) async {
    try {
      if (document.path == null || document.path!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File path not available')),
        );
        return;
      }
      
      // Show progress indicator first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.teal),
                const SizedBox(height: 20),
                Text('Preparing to download ${document.name}...', 
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      );
      
      // Get the download directory without requiring permissions first
      Directory? directory;
      try {
        if (Platform.isAndroid) {
          // Try to use the app's external directory which doesn't require permissions
          directory = await getExternalStorageDirectory();
          
          // If that fails, try the app's documents directory
          if (directory == null) {
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        // Fallback to app documents directory
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory != null) {
        final downloadPath = directory.path;
        final sourceFile = File(document.path!);
        final destinationFile = File('$downloadPath/${document.name}');
        
        // Copy the file
        await sourceFile.copy(destinationFile.path);
        
        // Close the progress dialog
        Navigator.of(context).pop();
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text('Download Complete', style: TextStyle(fontSize: 20)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File has been downloaded to:', 
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      destinationFile.path,
                      style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: TextStyle(fontSize: 16, color: Colors.teal)),
                ),
              ],
            );
          },
        );
      } else {
        // Close the progress dialog
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access download directory')),
        );
      }
    } catch (e) {
      // Close the progress dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  void _showDocumentOptions(DocumentItem document) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove_red_eye, color: Colors.teal),
                title: const Text('View'),
                onTap: () {
                  Navigator.pop(context);
                  _viewDocument(document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.teal),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                  _downloadDocument(document);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.teal),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement document sharing functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sharing ${document.name}')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(document);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(DocumentItem document) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete "${document.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                setState(() {
                  // Remove from both lists
                  documents.remove(document);
                  allDocuments.remove(document);
                });
                
                await _saveData();
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${document.name} deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteFolder(FolderItem folder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Folder'),
          content: Text('Are you sure you want to delete "${folder.name}" and all its contents?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                // Remove the folder and its contents
                setState(() {
                  // Remove from displayed folders
                  folders.remove(folder);
                  
                  // Remove from all folders
                  allFolders.remove(folder);
                  
                  // Remove all documents in this folder from both lists
                  documents.removeWhere((doc) => doc.folder == folder.name);
                  allDocuments.removeWhere((doc) => doc.folder == folder.name);
                  
                  // Remove all subfolders from both lists
                  List<String> foldersToRemove = [folder.name];
                  
                  // Find all nested subfolders recursively
                  bool foundMore = true;
                  while (foundMore) {
                    foundMore = false;
                    List<String> newFoldersToRemove = [];
                    
                    for (var f in allFolders) {
                      if (foldersToRemove.contains(f.parentFolder) && 
                          !foldersToRemove.contains(f.name)) {
                        newFoldersToRemove.add(f.name);
                        foundMore = true;
                      }
                    }
                    
                    foldersToRemove.addAll(newFoldersToRemove);
                  }
                  
                  // Remove all found subfolders
                  allFolders.removeWhere((f) => foldersToRemove.contains(f.name));
                  folders.removeWhere((f) => foldersToRemove.contains(f.name));
                  
                  // Remove all documents in subfolders
                  allDocuments.removeWhere((doc) => foldersToRemove.contains(doc.folder));
                  documents.removeWhere((doc) => foldersToRemove.contains(doc.folder));
                });
                
                await _saveData();
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Folder ${folder.name} deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  } 

  void _showFolderOptions(FolderItem folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.teal),
                title: const Text('Rename'),
                onTap: () {
                  Navigator.pop(context);
                  _renameFolder(folder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteFolder(folder);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _renameFolder(FolderItem folder) {
    final TextEditingController folderNameController = TextEditingController(text: folder.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: 'Enter new folder name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              onPressed: () async {
                if (folderNameController.text.isNotEmpty) {
                  // Find the index of the folder
                  final index = folders.indexOf(folder);
                  if (index != -1) {
                    // Create a new folder with the updated name
                    final updatedFolder = FolderItem(
                      name: folderNameController.text,
                      dateCreated: folder.dateCreated,
                      parentFolder: folder.parentFolder,
                    );
                    
                    setState(() {
                      // Replace the old folder with the updated one
                      folders[index] = updatedFolder;
                      
                      // Update folder path if we're in this folder
                      if (currentFolder == folder.name) {
                        currentFolder = updatedFolder.name;
                        final pathIndex = folderPath.indexOf(folder.name);
                        if (pathIndex != -1) {
                          folderPath[pathIndex] = updatedFolder.name;
                        }
                      }
                      
                      // Update folder references in documents
                      for (var i = 0; i < documents.length; i++) {
                        if (documents[i].folder == folder.name) {
                          documents[i] = DocumentItem(
                            name: documents[i].name,
                            size: documents[i].size,
                            dateAdded: documents[i].dateAdded,
                            type: documents[i].type,
                            path: documents[i].path,
                            folder: updatedFolder.name,
                          );
                        }
                      }
                      
                      // Update parent folder references in subfolders
                      for (var i = 0; i < folders.length; i++) {
                        if (folders[i].parentFolder == folder.name) {
                          folders[i] = FolderItem(
                            name: folders[i].name,
                            dateCreated: folders[i].dateCreated,
                            parentFolder: updatedFolder.name,
                          );
                        }
                      }
                    });
                    
                    await _saveData();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Folder renamed to ${updatedFolder.name}')),
                    );
                  }
                  
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Document Submission'),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const ScreenHeader(screenName: "Document Submission"),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: folderPath.map((folder) {
                        final isLast = folder == folderPath.last;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: isLast ? null : () {
                                setState(() {
                                  while (folderPath.last != folder) {
                                    folderPath.removeLast();
                                  }
                                  currentFolder = folder;
                                  isLoading = true;
                                });
                                _loadSavedData();
                              },
                              child: Text(
                                folder,
                                style: TextStyle(
                                  color: isLast ? Colors.teal : Colors.blue,
                                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (!isLast) 
                              const Text(' > ', style: TextStyle(color: Colors.grey)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (folderPath.length > 1)
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.teal),
                    onPressed: _navigateUp,
                    tooltip: 'Go up',
                  ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : folders.isEmpty && documents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No documents found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload documents or create a folder',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Folders section
                          if (folders.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Text(
                                'Folders',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            ...folders.map((folder) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 1,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.folder, color: Colors.amber[800], size: 24),
                                ),
                                title: Text(
                                  folder.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  'Created ${DateFormat('MMM d, yyyy').format(folder.dateCreated)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                onTap: () => _navigateToFolder(folder),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showFolderOptions(folder),
                                ),
                              ),
                            )).toList(),
                          ],
                          
                          // Documents section
                          if (documents.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 4),
                              child: Text(
                                'Documents',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            ...documents.map((document) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 1,
                              child: ListTile(
                                leading: _getDocumentIcon(document.type),
                                title: Text(
                                  document.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  '${document.size} • ${DateFormat('MMM d, yyyy').format(document.dateAdded)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                onTap: () => _showDocumentOptions(document),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () => _showDocumentOptions(document),
                                ),
                              ),
                            )).toList(),
                          ],
                        ],
                      ),
          ),
        ],
      ),
floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'home',
            backgroundColor: Colors.blue,
            mini: true,
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
            child: const Icon(Icons.home, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'createFolder',
            backgroundColor: Colors.amber,
            mini: true,
            onPressed: _createFolder,
            child: const Icon(Icons.create_new_folder, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'uploadFile',
            backgroundColor: Colors.teal,
            onPressed: _pickFile,
            child: const Icon(Icons.upload_file, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
        );
      case DocumentType.image:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, color: Colors.blue, size: 24),
        );
      case DocumentType.document:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description, color: Colors.indigo, size: 24),
        );
      case DocumentType.spreadsheet:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.table_chart, color: Colors.green, size: 24),
        );
      case DocumentType.presentation:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.slideshow, color: Colors.orange, size: 24),
        );
      case DocumentType.other:
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.insert_drive_file, color: Colors.grey, size: 24),
        );
    }
  }
}

class DocumentItem {
  final String name;
  final String size;
  final DateTime dateAdded;
  final DocumentType type;
  final String? path;
  final String folder;

  DocumentItem({
    required this.name,
    required this.size,
    required this.dateAdded,
    required this.type,
    this.path,
    required this.folder,
  });
}

class FolderItem {
  final String name;
  final DateTime dateCreated;
  final String parentFolder;

  FolderItem({
    required this.name,
    required this.dateCreated,
    required this.parentFolder,
  });
}

enum DocumentType {
  folder,
  pdf,
  image,
  document,
  spreadsheet,
  presentation,
  other,
}

// Helper function for byte calculation
double log(num x, [num? base]) {
  return math.log(x) / math.log(base ?? 10);
}

double pow(num x, num exponent) {
  return math.pow(x, exponent).toDouble();
}