import 'package:network_kit_lite/network_kit_lite.dart';
import 'package:dio/dio.dart';

/// 基于 Endpoint 的 API 调用示例
class EndpointExample {
  late final DioClient _dioClient;

  /// 初始化
  Future<void> initialize() async {
    _dioClient = DioClient();
    await _dioClient.init(
      baseUrl: 'https://api.example.com',
      enableCache: true,
      cacheType: CacheType.memory,
      enableLogging: true,
      enableAuth: true,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 1),
    );
  }

  /// 数据处理方法对比示例
  Future<void> _dataProcessingComparisonExample() async {
    print('--- 数据处理方法对比示例 ---');
    print('展示 resultWrapper、resultWrapperList 和传统 when 方法的区别\n');
    
    // 1. resultWrapper - 适用于单个对象的数据转换
    print('1️⃣ resultWrapper 方法:');
    print('   - 适用于: 单个对象的响应数据');
    print('   - 特点: 在 BaseResponse 级别进行数据转换');
    print('   - 用法: response.resultWrapper(creator: (json) => Entity.fromJson(json))');
    print('   - 返回: ResponseWrapper<T>');
    print('');
    
    // 2. resultWrapperList - 适用于列表数据的转换
    print('2️⃣ resultWrapperList 方法:');
    print('   - 适用于: 列表类型的响应数据');
    print('   - 特点: 自动处理列表遍历和数据转换');
    print('   - 用法: response.resultWrapperList(creator: (json) => Entity.fromJson(json))');
    print('   - 返回: ResponseWrapper<List<T>>');
    print('');
    
    // 3. 传统 when 方法 - 适用于异步响应处理
    print('3️⃣ 传统 when 方法:');
    print('   - 适用于: Future<ResponseWrapper<T>> 的异步处理');
    print('   - 特点: 提供 success、error、complete 回调');
    print('   - 用法: future.when(success: (data) {}, error: (error) {}, complete: () {})');
    print('   - 返回: Future<void>');
    print('');
    
    // 4. 使用场景建议
    print('📋 使用场景建议:');
    print('   • 获取单个用户信息 → 使用 resultWrapper');
    print('   • 获取用户列表 → 使用 resultWrapperList');
    print('   • 需要统一错误处理 → 使用传统 when 方法');
    print('   • 需要加载状态管理 → 使用传统 when 方法');
    print('');
  }

  /// 运行所有示例
  Future<void> runExamples() async {
    print('=== Endpoint API 示例 ===\n');
    
    try {
      // 数据处理方法对比
      await _dataProcessingComparisonExample();
      
      // 示例1: 获取用户列表
      await _getUserListExample();
      
      // 示例2: 创建用户
      await _createUserExample();
      
      // 示例3: 获取设备列表
      await _getDeviceListExample();
      
      // 示例4: 绑定设备
      await _bindDeviceExample();
      
      // 示例5: 带查询参数的请求
      await _searchUsersExample();
      
    } catch (e) {
      print('示例运行出错: $e');
    }
  }

  /// 示例1: 获取用户列表
  Future<void> _getUserListExample() async {
    print('--- 示例1: 获取用户列表 ---');
    
    final endpoint = UserListEndpoint();
    final result = await _dioClient.executeEndpoint(endpoint);
    
    result.when(
      success: (data) {
        print('✅ 获取用户列表成功:');
        print('用户数量: ${data.length}');
        for (final user in data) {
          print('  - ${user.name} (${user.email})');
        }
      },
      error: (error) {
        print('❌ 获取用户列表失败: $error');
      },
      complete: () {
        print('用户列表请求完成\n');
      },
    );
  }

  /// 示例2: 创建用户
  Future<void> _createUserExample() async {
    print('--- 示例2: 创建用户 ---');
    
    final userData = UserEntity(
      id: '',
      name: '张三',
      email: 'zhangsan@example.com',
      age: 25,
    );
    
    final endpoint = CreateUserEndpoint(userData);
    final result = await _dioClient.executeEndpoint(endpoint);
    
    result.when(
      success: (data) {
        print('✅ 创建用户成功:');
        print('用户ID: ${data['id']}');
        print('状态: ${data['status']}');
      },
      error: (error) {
        print('❌ 创建用户失败: $error');
      },
      complete: () {
        print('创建用户请求完成\n');
      },
    );
  }

  /// 示例3: 获取设备列表 - 展示 resultWrapperList 的使用
  Future<void> _getDeviceListExample() async {
    print('--- 示例3: 获取设备列表 (resultWrapperList) ---');
    
    try {
      // 执行网络请求
      final endpoint = DeviceListEndpoint();
      final response = await _dioClient.executeEndpoint(endpoint);
      
      // 方法1: 使用 resultWrapperList 进行数据转换
      final result = response.resultWrapperList<DeviceEntity>(
        creator: (json) {
          print('🔄 转换设备数据: $json');
          
          // 数据验证
          if (json == null) {
            throw ArgumentError('设备数据不能为空');
          }
          
          if (json is! Map<String, dynamic>) {
            throw ArgumentError('设备数据格式错误，期望 Map<String, dynamic>，实际: ${json.runtimeType}');
          }
          
          // 转换为设备实体对象
          return DeviceEntity.fromJson(json);
        }
      );
      
      // 处理转换后的结果
      if (result.isSuccessWithData) {
        final devices = result.data ?? [];
        print('✅ 获取设备列表成功:');
        print('设备数量: ${devices.length}');
        for (final device in devices) {
          print('  - ${device.name} (${device.id})');
        }
        
        // 可选：进一步处理数据
        final onlineDevices = devices.where((device) => device.isOnline).toList();
        print('在线设备数量: ${onlineDevices.length}');
      } else {
        print('❌ 获取设备列表失败: ${result.message}');
      }
      
    } catch (e) {
      print('❌ 获取设备列表异常: $e');
    }
    
    print('设备列表请求完成\n');
  }

  /// 示例4: 绑定设备 - 展示 resultWrapper 的使用
  Future<void> _bindDeviceExample() async {
    print('--- 示例4: 绑定设备 (resultWrapper) ---');
    
    try {
      // 执行网络请求
      final endpoint = BindDeviceEndpoint('device_123', 'user_456');
      final response = await _dioClient.executeEndpoint(endpoint);
      
      // 方法2: 使用 resultWrapper 进行单个对象数据转换
      final result = response.resultWrapper<BindResult>(
        creator: (json) {
          print('🔄 转换绑定结果数据: $json');
          
          // 数据验证
          if (json == null) {
            throw ArgumentError('绑定结果数据不能为空');
          }
          
          if (json is! Map<String, dynamic>) {
            throw ArgumentError('绑定结果数据格式错误');
          }
          
          // 转换为绑定结果对象
          return BindResult.fromJson(json);
        }
      );
      
      // 处理转换后的结果
      if (result.isSuccessWithData) {
        final bindResult = result.data!;
        print('✅ 设备绑定成功:');
        print('绑定结果: ${bindResult.success}');
        print('消息: ${bindResult.message}');
        print('设备ID: ${bindResult.deviceId}');
      } else {
        print('❌ 设备绑定失败: ${result.message}');
      }
      
    } catch (e) {
      print('❌ 设备绑定异常: $e');
    }
    
    print('绑定设备请求完成\n');
  }

  /// 示例5: 搜索用户 - 展示传统 when 方法的使用
  Future<void> _searchUsersExample() async {
    print('--- 示例5: 搜索用户 (传统 when 方法) ---');
    
    final endpoint = SearchUsersEndpoint(
      keyword: '张',
      page: 1,
      pageSize: 10,
    );
    
    // 方法3: 使用传统的 when 扩展方法处理 ResponseWrapper<T>
     final result = await _dioClient.executeEndpoint(endpoint);
     
     result.when(
       success: (data) {
         print('✅ 搜索用户成功:');
         print('用户数量: ${data.length}');
         for (final user in data) {
           print('  - ${user.name} (${user.email})');
         }
         
         // 可以在这里进行进一步的数据处理
         final activeUsers = data.where((user) => user.isActive).toList();
         print('活跃用户数量: ${activeUsers.length}');
       },
       error: (error) {
         print('❌ 搜索用户失败: ${error.message}');
         print('错误代码: ${error.code}');
         
         // 根据错误类型进行不同处理
         if (error.code == 401) {
           print('需要重新登录');
         } else if (error.code == 429) {
           print('请求过于频繁，请稍后再试');
         }
       },
       complete: () {
         print('搜索用户请求完成\n');
       },
     );
  }
}

// ============================================================================
// 数据模型定义
// ============================================================================

/// 用户实体
class UserEntity {
  final String id;
  final String name;
  final String email;
  final int age;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
    };
  }
}

/// 绑定结果类
class BindResult {
  final bool success;
  final String message;
  final String? deviceId;
  final DateTime? bindTime;

  BindResult({
    required this.success,
    required this.message,
    this.deviceId,
    this.bindTime,
  });

  factory BindResult.fromJson(Map<String, dynamic> json) {
    return BindResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      deviceId: json['deviceId'],
      bindTime: json['bindTime'] != null 
          ? DateTime.tryParse(json['bindTime']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'deviceId': deviceId,
      'bindTime': bindTime?.toIso8601String(),
    };
  }
}

/// 设备实体
class DeviceEntity {
  final String id;
  final String name;
  final String type;
  final bool isOnline;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.isOnline,
  });

  factory DeviceEntity.fromJson(Map<String, dynamic> json) {
    return DeviceEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isOnline: json['isOnline'] as bool,
    );
  }
}

// ============================================================================
// Endpoint 定义
// ============================================================================

/// 获取用户列表的 Endpoint
class UserListEndpoint extends ListAPIEndpoint<UserEntity> {
  @override
  String get path => '/api/users';

  @override
  String get module => 'app';

  @override
  HTTPMethod get httpMethod => HTTPMethod.get;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get requestBody => null;

  @override
  UserEntity parseElement(dynamic element) {
    return UserEntity.fromJson(element as Map<String, dynamic>);
  }
}

/// 创建用户的 Endpoint
class CreateUserEndpoint extends GenericAPIEndpoint<Map<String, dynamic>> {
  final UserEntity userData;

  CreateUserEndpoint(this.userData);

  @override
  String get path => '/api/users';

  @override
  String get module => 'app';

  @override
  HTTPMethod get httpMethod => HTTPMethod.post;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get requestBody => userData.toJson();

  @override
  Map<String, dynamic> parseItem(dynamic item) {
    return item as Map<String, dynamic>;
  }
}

/// 获取设备列表的 Endpoint
class DeviceListEndpoint extends ListAPIEndpoint<DeviceEntity> {
  @override
  String get path => '/api/devices';

  @override
  String get module => 'app';

  @override
  HTTPMethod get httpMethod => HTTPMethod.get;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get requestBody => null;

  @override
  DeviceEntity parseElement(dynamic element) {
    return DeviceEntity.fromJson(element as Map<String, dynamic>);
  }
}

/// 绑定设备的 Endpoint
class BindDeviceEndpoint extends GenericAPIEndpoint<Map<String, dynamic>> {
  final String deviceId;
  final String userId;

  BindDeviceEndpoint(this.deviceId, this.userId);

  @override
  String get path => '/api/devices/bind';

  @override
  String get module => 'app';

  @override
  HTTPMethod get httpMethod => HTTPMethod.post;

  @override
  Map<String, dynamic>? get queryParameters => null;

  @override
  dynamic get requestBody => {
    'deviceId': deviceId,
    'userId': userId,
  };

  @override
  Map<String, dynamic> parseItem(dynamic item) {
    return item as Map<String, dynamic>;
  }
}

/// 搜索用户的 Endpoint
class SearchUsersEndpoint extends ListAPIEndpoint<UserEntity> {
  final String keyword;
  final int page;
  final int pageSize;

  SearchUsersEndpoint({
    required this.keyword,
    required this.page,
    required this.pageSize,
  });

  @override
  String get path => '/api/users/search';

  @override
  String get module => 'app';

  @override
  HTTPMethod get httpMethod => HTTPMethod.get;

  @override
  Map<String, dynamic>? get queryParameters => {
    'keyword': keyword,
    'page': page,
    'pageSize': pageSize,
  };

  @override
  dynamic get requestBody => null;

  @override
  UserEntity parseElement(dynamic element) {
    return UserEntity.fromJson(element as Map<String, dynamic>);
  }
}

// ============================================================================
// 主函数示例
// ============================================================================

/// 运行示例的主函数
Future<void> main() async {
  print('🚀 开始运行 Endpoint API 示例\n');
  
  final example = EndpointExample();
  
  try {
    // 初始化客户端
    await example.initialize();
    print('✅ DioClient 初始化成功\n');
    
    // 运行所有示例
    await example.runExamples();
    
  } catch (e) {
    print('❌ 示例运行失败: $e');
  }
  
  print('🎉 Endpoint API 示例运行完成');
}

/// 如何在实际项目中使用的示例
class RealWorldUsage {
  late final DioClient _dioClient;

  /// 在实际项目中的初始化
  Future<void> initializeForProduction() async {
    _dioClient = DioClient();
    await _dioClient.init(
      baseUrl: 'https://your-api-server.com',
      enableCache: true,
      cacheType: CacheType.memory, // 使用内存缓存
      enableLogging: false, // 生产环境关闭日志
      enableAuth: true,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 2),
      // 超时配置通过 endpoint 的方法设置
    );
  }

  /// 在 Flutter Widget 中使用的示例
  Future<List<UserEntity>> loadUsers() async {
    final endpoint = UserListEndpoint();
    final result = await _dioClient.executeEndpoint(endpoint);
    
    return result.when(
      success: (users) => users,
      error: (error) {
        // 在实际项目中，这里可以显示错误提示给用户
        print('加载用户失败: $error');
        return <UserEntity>[];
      },
      complete: () => <UserEntity>[],
    );
  }

  /// 错误处理示例
  Future<bool> createUserWithErrorHandling(UserEntity user) async {
    try {
      final endpoint = CreateUserEndpoint(user);
      final result = await _dioClient.executeEndpoint(endpoint);
      
      return result.when(
        success: (data) {
          print('用户创建成功: ${data['id']}');
          return true;
        },
        error: (error) {
          // 根据不同的错误类型进行处理
          if (error.contains('网络')) {
            print('网络错误，请检查网络连接');
          } else if (error.contains('401')) {
            print('认证失败，请重新登录');
          } else {
            print('创建用户失败: $error');
          }
          return false;
        },
        complete: () => false,
      );
    } catch (e) {
      print('未知错误: $e');
      return false;
    }
  }
}