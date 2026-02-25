# FloBloom 功能组件索引

## 通用组件

暂无

## 工具方法

### 类名：`ImagePickerHelper`

**路径：** `lib/utils/image_picker_helper.dart`  
**功能：** 图片选择工具类

**方法：**

- `pickImage()`：从相册选择图片，返回 `File?`
- `pickImageFromCamera()`：使用相机拍照，返回 `File?`

**示例：**
```dart
final file = await ImagePickerHelper.pickImage();
if (file != null) {
  // 处理图片
}
```

---

### 类名：`ImageProcessor`

**路径：** `lib/utils/image_processor.dart`  
**功能：** 图片处理工具类

**方法：**

- `getImageInfo(File imageFile)`：获取图片信息（宽度、高度、文件大小）
- `cropImage({required File imageFile, required int x, required int y, required int width, required int height, int quality = 90})`：裁剪图片
- `rotateImage({required File imageFile, required int angle})`：旋转图片（90/180/270度）
- `flipImage({required File imageFile, required bool horizontal})`：翻转图片（水平/垂直）
- `saveImage({required File imageFile, required int width, required int height, required String extension})`：保存图片到本地
- `generateThumbnail({required File imageFile, int maxSize = 200})`：生成缩略图

**示例：**
```dart
// 裁剪图片
final croppedFile = await ImageProcessor.cropImage(
  imageFile: imageFile,
  x: 0,
  y: 0,
  width: 500,
  height: 500,
);
```

---

### 类名：`ImageFilterHelper`

**路径：** `lib/utils/image_filter_helper.dart`  
**功能：** 图片滤镜工具类

**方法：**

- `applyFilter({required File imageFile, required String filterName})`：应用滤镜到图片，返回 `File?`
- `getFilterList()`：获取可用滤镜列表

**支持的滤镜：**

- `None`：无滤镜
- `Rose Twilight`：玫瑰暮色（浪漫粉色调）
- `Cherry Dream`：樱花粉梦（柔和粉色）
- `Pure B&W`：纯粹黑白
- `Vintage`：古早经典（复古棕褐色）
- `Glamour`：璀璨华丽（高饱和度）
- `Lavender`：薰衣草紫（紫色调）
- `Moonlight`：月光银纱（冷色调）
- `Warm Memory`：暖调回忆（温暖橙色调）

**示例：**
```dart
final filtered = await ImageFilterHelper.applyFilter(
  imageFile: imageFile,
  filterName: 'Rose Twilight',
);
if (filtered != null) {
  // 使用滤镜后的图片
}
```

---

### 类名：`Toast工具`

**路径：** `lib/utils/index.dart`  
**功能：** 显示提示消息

**方法：**

- `successToast(String msg)`：显示成功提示（绿色）
- `errorToast(String msg)`：显示错误提示（红色）

**示例：**
```dart
successToast('保存成功');
errorToast('操作失败');
```

---

## 数据库

### 类名：`FloBloomDatabase`

**路径：** `lib/db_flo_bloom/data.dart`  
**功能：** FloBloom 数据库管理

**方法：**

- `insertRecord(FloBloomRecord record)`：插入记录
- `getAllRecords()`：获取所有记录
- `getRecordById(int id)`：根据ID获取记录
- `updateRecord(FloBloomRecord record)`：更新记录
- `deleteRecord(int id)`：删除记录
- `deleteAllRecords()`：删除所有记录
- `getRecordsByType(bool isAnimated)`：按类型获取记录

---

### 类名：`FloBloomRecord`

**路径：** `lib/db_flo_bloom/db_flo_bloom_entity.dart`  
**功能：** FloBloom 记录实体类

**参数：**

- `filePath`：处理后的文件路径
- `originalPath`：原始文件路径
- `createTime`：创建时间（毫秒时间戳）
- `fileSize`：文件大小（字节）
- `resolution`：分辨率（如 "1080x1920"）
- `isAnimated`：是否为动画（0/1）
- `filterName`：滤镜名称
- `stickers`：贴纸信息（JSON）
- `effectName`：特效名称
- `hasBeauty`：是否有美颜（0/1）
- `hasCrop`：是否有裁剪（0/1）
- `hasFrame`：是否有相框（0/1）
- `hasWatermark`：是否有水印（0/1）

---

## 服务

暂无

---

## 页面

### 滤镜编辑器

**路径：** `lib/pages/flo_bloom_filter_editor/`  
**功能：** 图片滤镜编辑功能

**特性：**

- 支持 9 种滤镜效果（浪漫、复古、黑白等风格）
- 实时预览滤镜效果
- 自动保存滤镜记录到数据库
- 返回时提示未保存的更改
- 支持图片保存到本地

**使用：**
```dart
// 传入图片路径作为参数
Get.toNamed('/flo_bloom_filter_editor', arguments: imagePath);
```

---

### 裁剪编辑器

**路径：** `lib/pages/flo_bloom_crop_editor/`  
**功能：** 图片裁剪编辑功能

**特性：**

- 支持多种比例裁剪（Original、1:1、1:2、9:16、16:9、3:4、4:3）
- 可拖动裁剪框调整位置
- 支持图片缩放和平移
- 自动保存裁剪记录到数据库
- 返回时提示未保存的更改

**使用：**
```dart
// 传入图片路径作为参数
Get.toNamed('/crop_editor', arguments: imagePath);
```

---

## 颜色常量

### 类名：`FloBloomColors`

**路径：** `lib/utils/colors.dart`  
**功能：** FloBloom 颜色常量定义

**颜色：**

- `primaryLight`：主色浅色 (#FFE8B7C8)
- `primaryDeep`：主色深色 (#FFD89AB5)
- `accentGold1-3`：强调色金色系列
- `background`：背景色
- `textPrimary`：主文本颜色
- `textSecondary`：次文本颜色
- `primaryGradient`：主色渐变

---

**更新时间：** 2026-02-24
