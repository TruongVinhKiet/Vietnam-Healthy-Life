const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const fs = require('fs');

// ============================================================================
// PART 1: NEW VIETNAMESE FOODS WITH NUTRIENTS
// ============================================================================

const NEW_FOODS = [
  // RAU CỦ - VEGETABLES (20 foods)
  { name: 'Cải thảo', name_vi: 'Cải thảo', category: 'vegetables', 
    nutrients: {1:25, 2:1.5, 3:0.2, 4:5, 5:1.2, 11:200, 15:45, 24:105, 27:252, 29:0.8} },
  { name: 'Rau muống', name_vi: 'Rau muống', category: 'vegetables',
    nutrients: {1:19, 2:2.6, 3:0.2, 4:3.1, 5:2.1, 11:6300, 15:55, 24:77, 29:2.5} },
  { id: 2003, name: 'Rau dền', name_vi: 'Rau dền', category: 'vegetables',
    nutrients: {1:23, 2:2.3, 3:0.3, 4:4.0, 5:2.0, 11:2917, 15:43, 24:215, 29:2.3} },
  { id: 2004, name: 'Bí đỏ', name_vi: 'Bí đỏ', category: 'vegetables',
    nutrients: {1:26, 2:1.0, 3:0.1, 4:6.5, 5:0.5, 11:8510, 15:9, 24:21, 27:340} },
  { id: 2005, name: 'Bí đao', name_vi: 'Bí đao (Bầu)', category: 'vegetables',
    nutrients: {1:13, 2:0.6, 3:0.1, 4:3.0, 5:0.5, 15:13, 24:26, 27:150} },
  { id: 2006, name: 'Mướp đắng (Khổ qua)', name_vi: 'Mướp đắng', category: 'vegetables',
    nutrients: {1:17, 2:1.0, 3:0.2, 4:3.7, 5:2.8, 15:84, 24:19, 27:296} },
  { id: 2007, name: 'Su su (Su hào)', name_vi: 'Su su', category: 'vegetables',
    nutrients: {1:19, 2:0.8, 3:0.1, 4:4.5, 5:1.7, 15:7.7, 24:17, 27:125} },
  { id: 2008, name: 'Cà rốt', name_vi: 'Cà rốt', category: 'vegetables',
    nutrients: {1:41, 2:0.9, 3:0.2, 4:9.6, 5:2.8, 11:16706, 15:5.9, 24:33, 27:320} },
  { id: 2009, name: 'Khoai lang', name_vi: 'Khoai lang', category: 'vegetables',
    nutrients: {1:86, 2:1.6, 3:0.1, 4:20.1, 5:3.0, 11:14187, 15:2.4, 24:30, 27:337} },
  { id: 2010, name: 'Khoai tây', name_vi: 'Khoai tây', category: 'vegetables',
    nutrients: {1:77, 2:2.0, 3:0.1, 4:17.5, 5:2.1, 15:19.7, 24:12, 27:421} },
  { id: 2011, name: 'Cải bắp', name_vi: 'Cải bắp (Bắp cải)', category: 'vegetables',
    nutrients: {1:25, 2:1.3, 3:0.1, 4:5.8, 5:2.5, 15:36.6, 24:40, 27:170} },
  { id: 2012, name: 'Bắp cải tím', name_vi: 'Bắp cải tím', category: 'vegetables',
    nutrients: {1:31, 2:1.4, 3:0.2, 4:7.4, 5:2.1, 15:57, 24:45, 27:243} },
  { id: 2013, name: 'Rau cải ngọt', name_vi: 'Rau cải ngọt', category: 'vegetables',
    nutrients: {1:20, 2:2.0, 3:0.3, 4:3.2, 5:1.8, 11:3500, 15:30, 24:100, 29:1.5} },
  { id: 2014, name: 'Cải xanh', name_vi: 'Cải xanh', category: 'vegetables',
    nutrients: {1:13, 2:1.5, 3:0.2, 4:2.2, 5:1.0, 11:4000, 15:45, 24:105, 29:0.8} },
  { id: 2015, name: 'Cà chua', name_vi: 'Cà chua', category: 'vegetables',
    nutrients: {1:18, 2:0.9, 3:0.2, 4:3.9, 5:1.2, 11:833, 15:13.7, 24:10, 27:237} },
  { id: 2016, name: 'Dưa chuột', name_vi: 'Dưa chuột', category: 'vegetables',
    nutrients: {1:15, 2:0.7, 3:0.1, 4:3.6, 5:0.5, 15:2.8, 24:16, 27:147} },
  { id: 2017, name: 'Ớt chuông', name_vi: 'Ớt chuông', category: 'vegetables',
    nutrients: {1:31, 2:1.0, 3:0.3, 4:6.0, 5:2.1, 11:3131, 15:127.7, 24:7, 27:211} },
  { id: 2018, name: 'Đậu cove', name_vi: 'Đậu cove', category: 'legumes',
    nutrients: {1:31, 2:2.8, 3:0.2, 4:5.7, 5:2.6, 15:12.2, 24:37, 27:260} },
  { id: 2019, name: 'Đậu đũa', name_vi: 'Đậu đũa (Đậu que)', category: 'legumes',
    nutrients: {1:31, 2:1.8, 3:0.1, 4:7.1, 5:2.7, 15:16.3, 24:37, 27:209} },
  { id: 2020, name: 'Giá đỗ', name_vi: 'Giá đỗ', category: 'vegetables',
    nutrients: {1:30, 2:3.0, 3:0.2, 4:5.9, 5:1.8, 15:13.2, 24:13, 27:149} },

  // THỊT & PROTEIN - MEAT & PROTEIN (20 foods)
  { id: 2021, name: 'Thịt heo nạc', name_vi: 'Thịt heo nạc', category: 'meat',
    nutrients: {1:143, 2:20.5, 3:6.3, 4:0, 10:60, 16:0.7, 23:0.6, 29:0.9, 30:2.0} },
  { id: 2022, name: 'Thịt bò nạc', name_vi: 'Thịt bò nạc', category: 'meat',
    nutrients: {1:177, 2:20.0, 3:10.2, 4:0, 10:62, 23:2.6, 29:2.6, 30:4.5} },
  { id: 2023, name: 'Thịt gà (không da)', name_vi: 'Thịt gà', category: 'poultry',
    nutrients: {1:165, 2:31.0, 3:3.6, 4:0, 10:85, 18:13.7, 23:0.3, 29:0.9, 30:1.0} },
  { id: 2024, name: 'Thịt vịt', name_vi: 'Thịt vịt', category: 'poultry',
    nutrients: {1:132, 2:18.3, 3:5.9, 4:0, 10:84, 18:5.1, 23:0.9, 29:2.3} },
  { id: 2025, name: 'Trứng gà', name_vi: 'Trứng gà', category: 'eggs',
    nutrients: {1:155, 2:13.0, 3:11.0, 4:1.1, 10:424, 11:540, 23:1.1, 24:56, 29:1.8} },
  { id: 2026, name: 'Trứng vịt', name_vi: 'Trứng vịt', category: 'eggs',
    nutrients: {1:185, 2:13.0, 3:13.8, 4:1.5, 10:884, 23:3.8, 24:64, 29:3.8} },
  { id: 2027, name: 'Cá rô phi', name_vi: 'Cá rô phi', category: 'fish',
    nutrients: {1:96, 2:20.1, 3:1.7, 4:0, 10:50, 23:1.5, 25:170, 29:0.6, 34:38} },
  { id: 2028, name: 'Cá tra', name_vi: 'Cá tra', category: 'fish',
    nutrients: {1:105, 2:16.4, 3:3.7, 4:0, 10:47, 23:1.5, 42:0.13, 43:0.12} },
  { id: 2029, name: 'Cá chép', name_vi: 'Cá chép', category: 'fish',
    nutrients: {1:127, 2:17.8, 3:5.6, 4:0, 10:66, 23:1.5, 25:210, 29:1.2} },
  { id: 2030, name: 'Cá thu', name_vi: 'Cá thu', category: 'fish',
    nutrients: {1:139, 2:18.6, 3:6.3, 4:0, 10:53, 42:1.4, 43:1.6, 23:8.8} },
  { id: 2031, name: 'Tôm sú', name_vi: 'Tôm sú', category: 'seafood',
    nutrients: {1:106, 2:20.3, 3:1.7, 4:0.9, 10:152, 34:38, 30:1.1, 24:54} },
  { id: 2032, name: 'Tôm thẻ', name_vi: 'Tôm thẻ', category: 'seafood',
    nutrients: {1:99, 2:20.9, 3:1.1, 4:0.8, 10:161, 34:33, 30:1.2, 24:52} },
  { id: 2033, name: 'Mực ống', name_vi: 'Mực ống', category: 'seafood',
    nutrients: {1:92, 2:15.6, 3:1.4, 4:3.1, 10:233, 34:44, 30:1.5, 31:1.5} },
  { id: 2034, name: 'Nghêu', name_vi: 'Nghêu', category: 'seafood',
    nutrients: {1:86, 2:14.0, 3:1.0, 4:5.1, 10:40, 29:28, 23:16.3, 34:24.3} },
  { id: 2035, name: 'Đậu hũ (Đậu phụ)', name_vi: 'Đậu hũ', category: 'legumes',
    nutrients: {1:76, 2:8.0, 3:4.8, 4:1.9, 5:0.3, 24:350, 29:5.4, 26:30} },
  { id: 2036, name: 'Đậu phụ non (Tàu hủ)', name_vi: 'Đậu phụ non', category: 'legumes',
    nutrients: {1:55, 2:5.3, 3:2.7, 4:2.9, 24:200, 29:2.2, 26:20} },
  { id: 2037, name: 'Đậu nành', name_vi: 'Đậu nành', category: 'legumes',
    nutrients: {1:147, 2:12.9, 3:6.8, 4:11.0, 5:4.2, 24:197, 29:3.6, 22:165} },
  { id: 2038, name: 'Đậu xanh', name_vi: 'Đậu xanh', category: 'legumes',
    nutrients: {1:105, 2:7.0, 3:0.4, 4:19.0, 5:7.6, 22:159, 29:1.4, 26:48} },
  { id: 2039, name: 'Đậu đen', name_vi: 'Đậu đen', category: 'legumes',
    nutrients: {1:132, 2:8.9, 3:0.5, 4:23.7, 5:8.7, 22:149, 29:2.1, 26:70} },
  { id: 2040, name: 'Đậu đỏ', name_vi: 'Đậu đỏ (Đậu ván)', category: 'legumes',
    nutrients: {1:127, 2:8.7, 3:0.5, 4:22.8, 5:7.4, 22:230, 29:2.9, 26:74} },

  // TRÁI CÂY - FRUITS (20 foods)
  { id: 2041, name: 'Chuối tiêu', name_vi: 'Chuối tiêu', category: 'fruits',
    nutrients: {1:89, 2:1.1, 3:0.3, 4:22.8, 5:2.6, 15:8.7, 27:358, 26:27} },
  { id: 2042, name: 'Cam', name_vi: 'Cam', category: 'fruits',
    nutrients: {1:47, 2:0.9, 3:0.1, 4:11.8, 5:2.4, 15:53.2, 27:181, 24:40} },
  { id: 2043, name: 'Quýt', name_vi: 'Quýt', category: 'fruits',
    nutrients: {1:53, 2:0.8, 3:0.3, 4:13.3, 5:1.8, 15:26.7, 27:166, 24:37} },
  { id: 2044, name: 'Xoài', name_vi: 'Xoài', category: 'fruits',
    nutrients: {1:60, 2:0.8, 3:0.4, 4:15.0, 5:1.6, 11:1082, 15:36.4, 27:168} },
  { id: 2045, name: 'Đu đủ', name_vi: 'Đu đủ (Papaya)', category: 'fruits',
    nutrients: {1:43, 2:0.5, 3:0.3, 4:11.0, 5:1.7, 11:950, 15:60.9, 27:182} },
  { id: 2046, name: 'Dưa hấu', name_vi: 'Dưa hấu', category: 'fruits',
    nutrients: {1:30, 2:0.6, 3:0.2, 4:7.6, 5:0.4, 11:569, 15:8.1, 27:112} },
  { id: 2047, name: 'Dứa (Thơm)', name_vi: 'Dứa', category: 'fruits',
    nutrients: {1:50, 2:0.5, 3:0.1, 4:13.1, 5:1.4, 15:47.8, 26:12, 27:109} },
  { id: 2048, name: 'Ổi', name_vi: 'Ổi', category: 'fruits',
    nutrients: {1:68, 2:2.6, 3:1.0, 4:14.3, 5:5.4, 15:228.3, 24:18, 27:417} },
  { id: 2049, name: 'Bưởi', name_vi: 'Bưởi', category: 'fruits',
    nutrients: {1:42, 2:0.8, 3:0.04, 4:10.7, 5:1.0, 15:61.0, 27:135, 24:4} },
  { id: 2050, name: 'Nhãn', name_vi: 'Nhãn', category: 'fruits',
    nutrients: {1:60, 2:1.3, 3:0.1, 4:15.1, 5:1.1, 15:84, 27:266, 24:1} },
  { id: 2051, name: 'Vải thiều', name_vi: 'Vải', category: 'fruits',
    nutrients: {1:66, 2:0.8, 3:0.4, 4:16.5, 5:1.3, 15:71.5, 27:171, 24:5} },
  { id: 2052, name: 'Táo ta', name_vi: 'Táo', category: 'fruits',
    nutrients: {1:52, 2:0.3, 3:0.2, 4:13.8, 5:2.4, 15:4.6, 27:107, 24:6} },
  { id: 2053, name: 'Lê', name_vi: 'Lê', category: 'fruits',
    nutrients: {1:57, 2:0.4, 3:0.1, 4:15.2, 5:3.1, 15:4.3, 27:116, 24:9} },
  { id: 2054, name: 'Thanh long', name_vi: 'Thanh long', category: 'fruits',
    nutrients: {1:60, 2:1.2, 3:0.4, 4:12.9, 5:3.0, 15:20.5, 27:263, 24:8} },
  { id: 2055, name: 'Măng cụt', name_vi: 'Măng cụt', category: 'fruits',
    nutrients: {1:73, 2:0.4, 3:0.6, 4:17.9, 5:1.8, 15:2.9, 27:48, 24:12} },
  { id: 2056, name: 'Chôm chôm', name_vi: 'Chôm chôm', category: 'fruits',
    nutrients: {1:82, 2:0.7, 3:0.2, 4:20.9, 5:0.9, 15:4.9, 27:42, 24:22} },
  { id: 2057, name: 'Mận', name_vi: 'Mận', category: 'fruits',
    nutrients: {1:46, 2:0.7, 3:0.3, 4:11.4, 5:1.4, 15:9.5, 27:157, 24:6} },
  { id: 2058, name: 'Dâu tây', name_vi: 'Dâu tây', category: 'fruits',
    nutrients: {1:32, 2:0.7, 3:0.3, 4:7.7, 5:2.0, 15:58.8, 27:153, 24:16} },
  { id: 2059, name: 'Dưa lưới', name_vi: 'Dưa lưới (Cantaloupe)', category: 'fruits',
    nutrients: {1:34, 2:0.8, 3:0.2, 4:8.2, 5:0.9, 11:3382, 15:36.7, 27:267} },
  { id: 2060, name: 'Chanh', name_vi: 'Chanh', category: 'fruits',
    nutrients: {1:29, 2:1.1, 3:0.3, 4:9.3, 5:2.8, 15:53, 27:138, 24:26} },

  // NGŨ CỐC - GRAINS (15 foods)
  { id: 2061, name: 'Gạo tẻ trắng', name_vi: 'Gạo trắng', category: 'grains',
    nutrients: {1:130, 2:2.7, 3:0.3, 4:28.2, 5:0.4, 26:25, 25:115, 29:0.8} },
  { id: 2062, name: 'Gạo lứt', name_vi: 'Gạo lứt', category: 'grains',
    nutrients: {1:111, 2:2.6, 3:0.9, 4:23.0, 5:1.8, 26:43, 25:162, 29:0.5} },
  { id: 2063, name: 'Gạo nếp', name_vi: 'Gạo nếp', category: 'grains',
    nutrients: {1:97, 2:2.0, 3:0.2, 4:21.1, 5:0.9, 26:3, 25:26, 29:0.4} },
  { id: 2064, name: 'Yến mạch', name_vi: 'Yến mạch', category: 'grains',
    nutrients: {1:68, 2:2.4, 3:1.4, 4:12.0, 5:1.7, 26:10, 25:77, 29:0.9} },
  { id: 2065, name: 'Bột mì nguyên cám', name_vi: 'Bột mì nguyên cám', category: 'grains',
    nutrients: {1:340, 2:13.2, 3:2.5, 4:72.0, 5:10.7, 26:137, 25:346, 29:3.6} },
  { id: 2066, name: 'Bột gạo', name_vi: 'Bột gạo', category: 'grains',
    nutrients: {1:366, 2:6.0, 3:1.4, 4:80.1, 5:2.4, 26:10, 25:98, 29:0.4} },
  { id: 2067, name: 'Bún tươi', name_vi: 'Bún', category: 'grains',
    nutrients: {1:109, 2:1.8, 3:0.2, 4:25.0, 5:0.7, 26:7, 25:43, 29:0.3} },
  { id: 2068, name: 'Phở', name_vi: 'Bánh phở', category: 'grains',
    nutrients: {1:109, 2:1.6, 3:0.1, 4:25.9, 5:0.5, 26:6, 25:38, 29:0.2} },
  { id: 2069, name: 'Miến', name_vi: 'Miến', category: 'grains',
    nutrients: {1:351, 2:0.2, 3:0.1, 4:86.0, 5:0.5, 26:3, 25:9, 29:0.3} },
  { id: 2070, name: 'Bánh mì', name_vi: 'Bánh mì', category: 'grains',
    nutrients: {1:265, 2:9.0, 3:3.2, 4:49.0, 5:2.7, 26:22, 25:115, 29:3.0} },
  { id: 2071, name: 'Ngô', name_vi: 'Ngô (Bắp)', category: 'grains',
    nutrients: {1:86, 2:3.3, 3:1.4, 4:18.7, 5:2.0, 26:37, 25:89, 29:0.5} },
  { id: 2072, name: 'Khoai mì', name_vi: 'Khoai mì (Sắn)', category: 'grains',
    nutrients: {1:160, 2:1.4, 3:0.3, 4:38.1, 5:1.8, 27:271, 26:21, 25:27} },
  { id: 2073, name: 'Khoai môn', name_vi: 'Khoai môn', category: 'grains',
    nutrients: {1:112, 2:1.5, 3:0.2, 4:26.5, 5:4.1, 27:591, 26:33, 24:43} },
  { id: 2074, name: 'Củ năng', name_vi: 'Củ năng', category: 'vegetables',
    nutrients: {1:97, 2:1.4, 3:0.1, 4:23.9, 5:3.0, 27:584, 25:63, 24:11} },
  { id: 2075, name: 'Hạt sen', name_vi: 'Hạt sen', category: 'grains',
    nutrients: {1:89, 2:4.1, 3:0.5, 4:17.3, 5:4.9, 27:367, 25:168, 29:1.2} },

  // GIA VỊ & KHÁC - SEASONINGS (10 foods)
  { id: 2076, name: 'Tỏi', name_vi: 'Tỏi', category: 'seasonings',
    nutrients: {1:149, 2:6.4, 3:0.5, 4:33.1, 5:2.1, 15:31.2, 27:401, 24:181} },
  { id: 2077, name: 'Hành tây', name_vi: 'Hành tây', category: 'seasonings',
    nutrients: {1:40, 2:1.1, 3:0.1, 4:9.3, 5:1.7, 15:7.4, 27:146, 24:23} },
  { id: 2078, name: 'Hành lá', name_vi: 'Hành lá', category: 'seasonings',
    nutrients: {1:32, 2:1.8, 3:0.2, 4:7.3, 5:2.6, 11:997, 15:18.8, 24:72} },
  { id: 2079, name: 'Gừng', name_vi: 'Gừng', category: 'seasonings',
    nutrients: {1:80, 2:1.8, 3:0.8, 4:17.8, 5:2.0, 15:5, 27:415, 26:43} },
  { id: 2080, name: 'Sả', name_vi: 'Sả', category: 'seasonings',
    nutrients: {1:99, 2:1.8, 3:0.5, 4:25.3, 5:1.0, 15:2.6, 27:723, 24:65} },
  { id: 2081, name: 'Nấm hương', name_vi: 'Nấm hương', category: 'vegetables',
    nutrients: {1:34, 2:2.2, 3:0.5, 4:6.8, 5:2.5, 12:18, 30:0.5, 34:2.2} },
  { id: 2082, name: 'Nấm rơm', name_vi: 'Nấm rơm', category: 'vegetables',
    nutrients: {1:35, 2:3.1, 3:0.3, 4:6.5, 5:2.3, 18:5.2, 25:86, 27:356} },
  { id: 2083, name: 'Mè rang', name_vi: 'Mè (Vừng)', category: 'seeds',
    nutrients: {1:573, 2:17.7, 3:49.7, 4:23.4, 5:11.8, 24:975, 29:14.6, 30:7.8} },
  { id: 2084, name: 'Hạt điều', name_vi: 'Hạt điều', category: 'nuts',
    nutrients: {1:553, 2:18.2, 3:43.8, 4:30.2, 5:3.3, 26:292, 30:5.8, 31:2.2} },
  { id: 2085, name: 'Đậu phộng', name_vi: 'Đậu phộng (Lạc)', category: 'nuts',
    nutrients: {1:567, 2:25.8, 3:49.2, 4:16.1, 5:8.5, 26:168, 29:4.6, 30:3.3} },

  // SỮA & CHẾ PHẨM SỮA (10 foods)
  { id: 2086, name: 'Sữa tươi nguyên chất', name_vi: 'Sữa bò', category: 'dairy',
    nutrients: {1:61, 2:3.2, 3:3.3, 4:4.8, 24:113, 23:0.5, 25:84, 27:143} },
  { id: 2087, name: 'Sữa chua không đường', name_vi: 'Sữa chua', category: 'dairy',
    nutrients: {1:59, 2:3.5, 3:3.3, 4:4.7, 24:121, 23:0.4, 25:95, 27:155} },
  { id: 2088, name: 'Phô mai', name_vi: 'Phô mai', category: 'dairy',
    nutrients: {1:402, 2:25.0, 3:33.0, 4:1.3, 10:105, 24:721, 23:1.5, 28:621} },
  { id: 2089, name: 'Sữa đậu nành', name_vi: 'Sữa đậu nành', category: 'dairy',
    nutrients: {1:33, 2:2.9, 3:1.6, 4:1.7, 24:25, 29:0.5, 26:25} },
  { id: 2090, name: 'Sữa dê', name_vi: 'Sữa dê', category: 'dairy',
    nutrients: {1:69, 2:3.6, 3:4.1, 4:4.5, 24:134, 23:0.1, 25:111, 27:204} },
  { id: 2091, name: 'Bơ thực vật', name_vi: 'Bơ thực vật', category: 'dairy',
    nutrients: {1:717, 2:0.9, 3:81.0, 4:0.1, 11:819, 13:2.3, 24:24} },
  { id: 2092, name: 'Dầu ô liu', name_vi: 'Dầu ô liu', category: 'oils',
    nutrients: {1:884, 2:0, 3:100, 4:0, 13:14.4, 38:73.0, 39:10.5} },
  { id: 2093, name: 'Dầu đậu nành', name_vi: 'Dầu đậu nành', category: 'oils',
    nutrients: {1:884, 2:0, 3:100, 4:0, 38:23.3, 39:57.7, 40:15.6} },
  { id: 2094, name: 'Dầu vừng', name_vi: 'Dầu vừng (Mè)', category: 'oils',
    nutrients: {1:884, 2:0, 3:100, 4:0, 38:39.7, 39:41.7, 40:14.2} },
  { id: 2095, name: 'Mật ong', name_vi: 'Mật ong', category: 'sweeteners',
    nutrients: {1:304, 2:0.3, 3:0, 4:82.4, 15:0.5, 27:52, 24:6} },
];

// ============================================================================
// PART 2: COMPREHENSIVE FOOD RECOMMENDATIONS FOR ALL 39 CONDITIONS
// ============================================================================

const COMPREHENSIVE_FOOD_RECOMMENDATIONS = {
  // [1] Diabetes Type 2 - EXPANDED
  1: {
    avoid: [2, 5, 7, 13, 14, 2063, 2066, 2069, 2095, 2041, 2044, 2046, 2050, 2051, 2055, 2056], // sugars, refined grains, sweet fruits
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2006, 2008, 2011, 2013, 2014, 2015, 2018, 2019, 2023, 2027, 2028, 2035, 2037, 2038, 2039, 2040, 2062, 2064, 2048, 2049]
  },
  // [2] Hypertension - EXPANDED
  2: {
    avoid: [7, 8, 12, 13, 14, 25, 26, 2088, 2091, 2021, 2024, 2031, 2032, 2033, 2034], // high sodium, processed foods
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2005, 2008, 2009, 2011, 2013, 2041, 2042, 2043, 2044, 2045, 2046, 2048, 2049, 2062, 2064, 2075]
  },
  // [3] High Cholesterol - EXPANDED
  3: {
    avoid: [2, 7, 12, 13, 14, 2021, 2024, 2025, 2026, 2088, 2091, 2093], // saturated fat, cholesterol
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2035, 2036, 2037, 2038, 2039, 2040, 2062, 2064, 2002, 2003, 2008, 2011, 2041, 2042, 2048, 2083, 2092]
  },
  // [4] Fatty Liver - EXPANDED
  4: {
    avoid: [2, 5, 7, 12, 13, 14, 2063, 2095, 2021, 2024, 2091, 2093, 2041, 2050, 2051], // fat, sugar, alcohol
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2008, 2011, 2013, 2014, 2015, 2023, 2027, 2028, 2035, 2037, 2062, 2064, 2042, 2048, 2060]
  },
  // [5] Gout - EXPANDED
  5: {
    avoid: [2, 7, 8, 12, 13, 14, 2022, 2024, 2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2037, 2038, 2039, 2040, 2082], // purines
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2005, 2008, 2009, 2011, 2013, 2015, 2016, 2023, 2035, 2036, 2041, 2042, 2045, 2046, 2049, 2062, 2087]
  },
  // [6] Anemia - EXPANDED
  6: {
    avoid: [], // no major restrictions
    recommend: [2, 7, 12, 13, 14, 2021, 2022, 2023, 2024, 2025, 2027, 2028, 2029, 2030, 2002, 2003, 2008, 2009, 2013, 2014, 2038, 2039, 2040, 2062, 2086, 2087]
  },
  // [7] Osteoporosis - EXPANDED
  7: {
    avoid: [7, 8], // excess salt
    recommend: [1, 3, 4, 6, 9, 10, 11, 2025, 2086, 2087, 2088, 2090, 2035, 2036, 2002, 2003, 2008, 2011, 2013, 2027, 2028, 2042, 2048, 2083]
  },
  // [8] IBS - EXPANDED
  8: {
    avoid: [7, 8, 13, 14, 2021, 2024, 2037, 2038, 2039, 2040, 2077, 2076], // gas-producing
    recommend: [1, 3, 4, 6, 9, 10, 11, 2023, 2027, 2028, 2035, 2036, 2061, 2067, 2068, 2008, 2009, 2041, 2042, 2048, 2087]
  },
  // [9] GERD - EXPANDED
  9: {
    avoid: [7, 8, 13, 14, 2015, 2017, 2060, 2042, 2043, 2076, 2079], // acidic, spicy
    recommend: [1, 3, 4, 6, 9, 10, 11, 2004, 2005, 2008, 2009, 2011, 2013, 2023, 2027, 2035, 2041, 2045, 2048, 2061, 2064, 2086, 2087]
  },
  // [10] Gastritis - EXPANDED
  10: {
    avoid: [7, 8, 13, 14, 2015, 2017, 2060, 2076, 2079], // irritating foods
    recommend: [1, 3, 4, 6, 9, 10, 11, 2004, 2005, 2008, 2009, 2011, 2023, 2027, 2035, 2041, 2045, 2048, 2061, 2064, 2086, 2087]
  },
  // [11] Peptic Ulcer - EXPANDED
  11: {
    avoid: [7, 8, 13, 14, 2015, 2017, 2060, 2076, 2079], // ulcer irritants
    recommend: [1, 3, 4, 6, 9, 10, 11, 2004, 2005, 2008, 2011, 2023, 2027, 2035, 2041, 2045, 2061, 2062, 2064, 2086, 2087]
  },
  // [12] Celiac Disease - EXPANDED
  12: {
    avoid: [2065, 2070], // gluten
    recommend: [2061, 2062, 2063, 2066, 2071, 2072, 2073, 2009, 2010, 2027, 2028, 2035, 2037, 2002, 2003, 2041, 2042, 2048]
  },
  // [13] Kidney Disease (E105) - NEW
  13: {
    avoid: [7, 8, 2021, 2022, 2024, 2025, 2037, 2038, 2039, 2040, 2086, 2088], // protein, sodium, phosphorus, potassium
    recommend: [1, 3, 4, 6, 2005, 2007, 2016, 2023, 2027, 2061, 2067, 2068, 2041, 2042, 2046, 2048]
  },
  // [14] Obesity (E660) - EXPANDED (shared with #1)
  14: {
    avoid: [2, 5, 7, 12, 13, 14, 2063, 2066, 2069, 2095, 2091, 2093, 2021, 2024, 2041, 2050, 2051, 2055, 2056, 2084, 2085],
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2005, 2006, 2008, 2011, 2013, 2014, 2015, 2016, 2018, 2019, 2023, 2027, 2028, 2035, 2062, 2064, 2048]
  },
  // [15] Malnutrition (E46) - NEW
  15: {
    avoid: [], // need dense nutrition
    recommend: [2, 7, 12, 13, 14, 2021, 2022, 2023, 2024, 2025, 2027, 2028, 2029, 2030, 2035, 2037, 2038, 2039, 2040, 2061, 2062, 2064, 2065, 2083, 2084, 2085, 2086, 2095]
  },
  // [16] Heart Failure (I50) - NEW
  16: {
    avoid: [7, 8, 12, 13, 14, 2021, 2024, 2088, 2091], // sodium, fat
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2008, 2011, 2013, 2023, 2027, 2028, 2030, 2035, 2062, 2064, 2041, 2042, 2048, 2092]
  },
  // [17] Coronary Artery Disease (I251) - same as #3
  17: {
    avoid: [2, 7, 12, 13, 14, 2021, 2024, 2025, 2026, 2088, 2091, 2093],
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2035, 2037, 2062, 2064, 2002, 2003, 2008, 2011, 2041, 2042, 2048, 2083, 2092]
  },
  // [18] Atherosclerosis (I702) - same as #3
  18: {
    avoid: [2, 7, 12, 13, 14, 2021, 2024, 2025, 2026, 2088, 2091, 2093],
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2035, 2037, 2062, 2064, 2002, 2003, 2008, 2011, 2041, 2042, 2048, 2083, 2092]
  },
  // [19] Asthma (J45) - NEW
  19: {
    avoid: [7, 8, 13, 14, 2088], // inflammatory foods
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2002, 2003, 2008, 2011, 2013, 2041, 2042, 2048, 2062, 2092]
  },
  // [20] COPD (J440) - NEW
  20: {
    avoid: [7, 8, 13, 14], // inflammatory
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2002, 2003, 2008, 2011, 2013, 2023, 2041, 2042, 2048, 2062, 2064, 2092]
  },
  // [21] Hypothyroidism (E039) - NEW
  21: {
    avoid: [2004, 2011, 2012, 2014, 2037], // goitrogens
    recommend: [2027, 2028, 2029, 2030, 2031, 2032, 2034, 2002, 2003, 2008, 2013, 2023, 2062, 2064, 2083]
  },
  // [22] Hyperthyroidism (E05) - NEW
  22: {
    avoid: [2027, 2028, 2029, 2030, 2031, 2032, 2033, 2034, 2083], // high iodine
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2008, 2011, 2013, 2023, 2035, 2061, 2062, 2041, 2042]
  },
  // [23] Rheumatoid Arthritis (M06) - NEW
  23: {
    avoid: [7, 8, 13, 14, 2021, 2024, 2091, 2093], // inflammatory
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2002, 2003, 2008, 2011, 2013, 2035, 2062, 2064, 2041, 2042, 2048, 2092]
  },
  // [24] Psoriasis (L40) - same as #23
  24: {
    avoid: [7, 8, 13, 14, 2021, 2024, 2091, 2093],
    recommend: [1, 3, 4, 6, 9, 10, 11, 2027, 2028, 2030, 2002, 2003, 2008, 2011, 2013, 2035, 2062, 2064, 2041, 2042, 2048, 2092]
  },
  // [25] Crohn's Disease (K50) - NEW
  25: {
    avoid: [7, 8, 13, 14, 2002, 2003, 2004, 2018, 2019, 2037, 2038, 2039, 2040, 2065], // fiber, gas
    recommend: [1, 3, 4, 6, 2023, 2027, 2028, 2035, 2036, 2061, 2067, 2068, 2008, 2009, 2041, 2045, 2087]
  },
  // [26] Ulcerative Colitis (K51) - same as #25
  26: {
    avoid: [7, 8, 13, 14, 2002, 2003, 2004, 2018, 2019, 2037, 2038, 2039, 2040, 2065],
    recommend: [1, 3, 4, 6, 2023, 2027, 2028, 2035, 2036, 2061, 2067, 2068, 2008, 2009, 2041, 2045, 2087]
  },
  // [27] Lactose Intolerance (E73) - NEW
  27: {
    avoid: [2086, 2087, 2088, 2090], // dairy
    recommend: [2089, 2035, 2036, 2037, 2002, 2003, 2008, 2027, 2028, 2041, 2042, 2048, 2062, 2064]
  },
  // [28] Food Allergy (T78) - NEW
  28: {
    avoid: [2037, 2084, 2085, 2083, 2031, 2032, 2033, 2034], // common allergens
    recommend: [1, 3, 4, 6, 2023, 2027, 2028, 2002, 2003, 2008, 2041, 2042, 2048, 2061, 2062]
  },
  // [29] Diverticulitis (K57) - NEW
  29: {
    avoid: [2083, 2084, 2085, 2071], // seeds, nuts, corn
    recommend: [1, 3, 4, 6, 2023, 2027, 2035, 2061, 2067, 2068, 2008, 2009, 2041, 2045, 2087]
  },
  // [30] Cirrhosis (K746) - NEW
  30: {
    avoid: [7, 8, 2021, 2022, 2024, 2025], // protein, sodium
    recommend: [1, 3, 4, 6, 2002, 2003, 2004, 2008, 2011, 2023, 2027, 2035, 2061, 2062, 2041, 2042, 2048]
  },
  // [31] Hepatitis B (B18) - same as #4
  31: {
    avoid: [2, 5, 7, 12, 13, 14, 2063, 2095, 2021, 2024, 2091, 2093],
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2008, 2011, 2013, 2023, 2027, 2028, 2035, 2037, 2062, 2064, 2042, 2048]
  },
  // [32] Hepatitis C (B182) - same as #4
  32: {
    avoid: [2, 5, 7, 12, 13, 14, 2063, 2095, 2021, 2024, 2091, 2093],
    recommend: [1, 3, 4, 6, 9, 10, 11, 2002, 2003, 2004, 2008, 2011, 2013, 2023, 2027, 2028, 2035, 2037, 2062, 2064, 2042, 2048]
  },
  // [33] Cholera (A00) - NEW
  33: {
    avoid: [7, 8, 13, 14, 2015, 2017], // avoid irritants during recovery
    recommend: [2061, 2067, 2068, 2041, 2045, 2046, 2087, 2008, 2009] // easy to digest
  },
  // [34] Typhoid (A01) - same as #33
  34: {
    avoid: [7, 8, 13, 14, 2015, 2017],
    recommend: [2061, 2067, 2068, 2041, 2045, 2046, 2087, 2008, 2009]
  },
  // [35] Tuberculosis (A15) - NEW
  35: {
    avoid: [], // need nutrition
    recommend: [2, 7, 12, 13, 14, 2021, 2022, 2023, 2024, 2025, 2027, 2028, 2035, 2037, 2061, 2062, 2064, 2086, 2095]
  },
  // [36] Pulmonary TB (A150) - same as #35
  36: {
    avoid: [],
    recommend: [2, 7, 12, 13, 14, 2021, 2022, 2023, 2024, 2025, 2027, 2028, 2035, 2037, 2061, 2062, 2064, 2086, 2095]
  },
  // [37] TB Meningitis (A170) - same as #35
  37: {
    avoid: [],
    recommend: [2, 7, 12, 13, 14, 2021, 2022, 2023, 2024, 2025, 2027, 2028, 2035, 2037, 2061, 2062, 2064, 2086, 2095]
  },
  // [38] E.coli Infection (A04) - same as #33
  38: {
    avoid: [7, 8, 13, 14, 2015, 2017, 2021, 2024],
    recommend: [2061, 2067, 2068, 2041, 2045, 2046, 2087, 2008, 2009, 2023, 2027]
  },
  // [39] TB Meningitis duplicate (A170) - same as #35
  39: {
    avoid: [],
    recommend: [2, 7, 12, 13, 14, 2021, 2022, 2023, 2024, 2025, 2027, 2028, 2035, 2037, 2061, 2062, 2064, 2086, 2095]
  },
};

// ============================================================================
// PART 3: 100+ COMPREHENSIVE VIETNAMESE DISHES
// ============================================================================

const COMPREHENSIVE_VIETNAMESE_DISHES = [
  // PHỞ & BÚN VARIETIES (15 dishes)
  { id: 3001, name: 'Phở bò', category: 'soup', ingredients: [2068, 2022, 2078, 2079, 2080] },
  { id: 3002, name: 'Phở gà', category: 'soup', ingredients: [2068, 2023, 2078, 2079, 2080] },
  { id: 3003, name: 'Phở chay', category: 'soup', ingredients: [2068, 2035, 2002, 2003, 2081, 2082] },
  { id: 3004, name: 'Bún bò Huế', category: 'soup', ingredients: [2067, 2022, 2080, 2017] },
  { id: 3005, name: 'Bún chả', category: 'dinner', ingredients: [2067, 2021, 2076, 2003, 2015] },
  { id: 3006, name: 'Bún riêu', category: 'soup', ingredients: [2067, 2031, 2015, 2035, 2003] },
  { id: 3007, name: 'Bún thịt nướng', category: 'dinner', ingredients: [2067, 2021, 2016, 2003, 2078] },
  { id: 3008, name: 'Bún măng vịt', category: 'soup', ingredients: [2067, 2024, 2074, 2081] },
  { id: 3009, name: 'Bún cá', category: 'soup', ingredients: [2067, 2027, 2015, 2003, 2060] },
  { id: 3010, name: 'Miến gà', category: 'soup', ingredients: [2069, 2023, 2081, 2078] },
  { id: 3011, name: 'Miến lươn', category: 'soup', ingredients: [2069, 2003, 2076, 2079] },
  { id: 3012, name: 'Hủ tiếu Nam Vang', category: 'soup', ingredients: [2067, 2021, 2031, 2020] },
  { id: 3013, name: 'Bún mọc', category: 'soup', ingredients: [2067, 2021, 2081, 2003] },
  { id: 3014, name: 'Bún ốc', category: 'soup', ingredients: [2067, 2015, 2003, 2076] },
  { id: 3015, name: 'Phở cuốn', category: 'lunch', ingredients: [2068, 2022, 2003, 2016] },

  // CƠM (RICE DISHES) (20 dishes)
  { id: 3016, name: 'Cơm gà xối mỡ', category: 'dinner', ingredients: [2061, 2023, 2016, 2015] },
  { id: 3017, name: 'Cơm tấm sườn', category: 'dinner', ingredients: [2061, 2021, 2016, 2015] },
  { id: 3018, name: 'Cơm gà Hải Nam', category: 'dinner', ingredients: [2061, 2023, 2016, 2078] },
  { id: 3019, name: 'Cơm hến', category: 'dinner', ingredients: [2061, 2003, 2076, 2017] },
  { id: 3020, name: 'Cơm chiên Dương Châu', category: 'dinner', ingredients: [2061, 2025, 2031, 2020, 2008] },
  { id: 3021, name: 'Cơm rang thập cẩm', category: 'dinner', ingredients: [2061, 2025, 2021, 2008, 2020] },
  { id: 3022, name: 'Cơm cà ri gà', category: 'dinner', ingredients: [2061, 2023, 2010, 2008] },
  { id: 3023, name: 'Cơm sườn nướng', category: 'dinner', ingredients: [2061, 2021, 2016, 2015] },
  { id: 3024, name: 'Cơm gà nướng', category: 'dinner', ingredients: [2061, 2023, 2016, 2015] },
  { id: 3025, name: 'Cơm cá kho tộ', category: 'dinner', ingredients: [2061, 2027, 2076, 2017] },
  { id: 3026, name: 'Cơm thịt kho tàu', category: 'dinner', ingredients: [2061, 2021, 2025, 2076] },
  { id: 3027, name: 'Cơm chay', category: 'vegetarian', ingredients: [2061, 2035, 2002, 2003, 2081] },
  { id: 3028, name: 'Cơm cá rô phi chiên', category: 'dinner', ingredients: [2061, 2027, 2016, 2015] },
  { id: 3029, name: 'Cơm cá thu kho', category: 'dinner', ingredients: [2061, 2030, 2076, 2079] },
  { id: 3030, name: 'Cơm gà luộc', category: 'dinner', ingredients: [2061, 2023, 2079, 2078] },
  { id: 3031, name: 'Cơm tôm rang me', category: 'dinner', ingredients: [2061, 2031, 2076, 2079] },
  { id: 3032, name: 'Cơm mực xào chua ngọt', category: 'dinner', ingredients: [2061, 2033, 2015, 2017] },
  { id: 3033, name: 'Cơm trứng chiên', category: 'breakfast', ingredients: [2061, 2025, 2078] },
  { id: 3034, name: 'Cơm rang dưa bò', category: 'dinner', ingredients: [2061, 2022, 2016, 2015] },
  { id: 3035, name: 'Cơm niêu', category: 'dinner', ingredients: [2061, 2021, 2081, 2080] },

  // CANH (SOUPS) (20 dishes)
  { id: 3036, name: 'Canh chua cá', category: 'soup', ingredients: [2027, 2015, 2004, 2020] },
  { id: 3037, name: 'Canh chua tôm', category: 'soup', ingredients: [2031, 2015, 2004, 2020] },
  { id: 3038, name: 'Canh khổ qua nhồi thịt', category: 'soup', ingredients: [2006, 2021, 2015] },
  { id: 3039, name: 'Canh bí đỏ', category: 'soup', ingredients: [2004, 2076, 2078] },
  { id: 3040, name: 'Canh rau ngót nấu tôm', category: 'soup', ingredients: [2003, 2031, 2076] },
  { id: 3041, name: 'Canh cải thảo thịt bằm', category: 'soup', ingredients: [2001, 2021, 2076] },
  { id: 3042, name: 'Canh rau muống', category: 'soup', ingredients: [2002, 2076, 2078] },
  { id: 3043, name: 'Canh miso đậu hũ', category: 'soup', ingredients: [2035, 2003, 2081] },
  { id: 3044, name: 'Canh nấm', category: 'soup', ingredients: [2081, 2082, 2035, 2078] },
  { id: 3045, name: 'Canh cá rô nấu ngót', category: 'soup', ingredients: [2027, 2003, 2076, 2079] },
  { id: 3046, name: 'Canh măng', category: 'soup', ingredients: [2074, 2021, 2076] },
  { id: 3047, name: 'Canh cải bắp cuộn thịt', category: 'soup', ingredients: [2011, 2021, 2015] },
  { id: 3048, name: 'Canh mướp đắng nhồi thịt', category: 'soup', ingredients: [2006, 2021, 2076] },
  { id: 3049, name: 'Canh su su nấu tôm', category: 'soup', ingredients: [2007, 2031, 2076] },
  { id: 3050, name: 'Canh hến', category: 'soup', ingredients: [2003, 2076, 2079, 2080] },
  { id: 3051, name: 'Canh bầu nấu tôm', category: 'soup', ingredients: [2005, 2031, 2076] },
  { id: 3052, name: 'Canh chua nghêu', category: 'soup', ingredients: [2034, 2015, 2003] },
  { id: 3053, name: 'Canh đậu hũ hải sản', category: 'soup', ingredients: [2035, 2031, 2033, 2078] },
  { id: 3054, name: 'Canh gà ác tiềm', category: 'soup', ingredients: [2023, 2076, 2079, 2080] },
  { id: 3055, name: 'Canh cá diêu hồng', category: 'soup', ingredients: [2027, 2015, 2076, 2079] },

  // MÓN XÀO (STIR-FRY) (20 dishes)
  { id: 3056, name: 'Rau muống xào tỏi', category: 'vegetarian', ingredients: [2002, 2076, 2078] },
  { id: 3057, name: 'Cải thảo xào nấm', category: 'vegetarian', ingredients: [2001, 2081, 2076] },
  { id: 3058, name: 'Thịt bò xào lúc lắc', category: 'dinner', ingredients: [2022, 2016, 2015, 2077] },
  { id: 3059, name: 'Gà xào sả ớt', category: 'dinner', ingredients: [2023, 2080, 2017, 2076] },
  { id: 3060, name: 'Mực xào sa tế', category: 'dinner', ingredients: [2033, 2077, 2076, 2017] },
  { id: 3061, name: 'Tôm xào thập cẩm', category: 'dinner', ingredients: [2031, 2008, 2011, 2081] },
  { id: 3062, name: 'Bò xào rau củ', category: 'dinner', ingredients: [2022, 2011, 2008, 2081] },
  { id: 3063, name: 'Gà xào gừng', category: 'dinner', ingredients: [2023, 2079, 2078, 2080] },
  { id: 3064, name: 'Thịt heo xào dứa', category: 'dinner', ingredients: [2021, 2047, 2017, 2077] },
  { id: 3065, name: 'Cá xào chua ngọt', category: 'dinner', ingredients: [2027, 2015, 2017, 2077] },
  { id: 3066, name: 'Đậu hũ xào rau củ', category: 'vegetarian', ingredients: [2035, 2008, 2011, 2081] },
  { id: 3067, name: 'Bò xào sả', category: 'dinner', ingredients: [2022, 2080, 2017, 2076] },
  { id: 3068, name: 'Mướp đắng xào trứng', category: 'vegetarian', ingredients: [2006, 2025, 2076] },
  { id: 3069, name: 'Bí đỏ xào tỏi', category: 'vegetarian', ingredients: [2004, 2076, 2078] },
  { id: 3070, name: 'Rau dền xào tỏi', category: 'vegetarian', ingredients: [2003, 2076, 2078] },
  { id: 3071, name: 'Thịt bò xào cải ngọt', category: 'dinner', ingredients: [2022, 2013, 2076, 2079] },
  { id: 3072, name: 'Gà xào cà ri', category: 'dinner', ingredients: [2023, 2010, 2008, 2077] },
  { id: 3073, name: 'Tôm xào bông cải', category: 'dinner', ingredients: [2031, 2011, 2008, 2076] },
  { id: 3074, name: 'Nấm xào thập cẩm', category: 'vegetarian', ingredients: [2081, 2082, 2008, 2011] },
  { id: 3075, name: 'Đậu que xào thịt', category: 'dinner', ingredients: [2019, 2021, 2076, 2079] },

  // MÓN LUỘC/HẤP (BOILED/STEAMED) (15 dishes)
  { id: 3076, name: 'Gà luộc', category: 'dinner', ingredients: [2023, 2079, 2078, 2080] },
  { id: 3077, name: 'Thịt luộc', category: 'dinner', ingredients: [2021, 2076, 2078] },
  { id: 3078, name: 'Tôm hấp', category: 'dinner', ingredients: [2031, 2076, 2079, 2080] },
  { id: 3079, name: 'Cá hấp', category: 'dinner', ingredients: [2027, 2079, 2078, 2080] },
  { id: 3080, name: 'Bí đỏ hấp', category: 'vegetarian', ingredients: [2004] },
  { id: 3081, name: 'Khoai lang luộc', category: 'vegetarian', ingredients: [2009] },
  { id: 3082, name: 'Khoai tây luộc', category: 'vegetarian', ingredients: [2010] },
  { id: 3083, name: 'Ngô luộc', category: 'vegetarian', ingredients: [2071] },
  { id: 3084, name: 'Trứng luộc', category: 'breakfast', ingredients: [2025] },
  { id: 3085, name: 'Cá kho', category: 'dinner', ingredients: [2027, 2076, 2079, 2060] },
  { id: 3086, name: 'Thịt kho tiêu', category: 'dinner', ingredients: [2021, 2076, 2025] },
  { id: 3087, name: 'Mực hấp', category: 'dinner', ingredients: [2033, 2076, 2079, 2080] },
  { id: 3088, name: 'Gà hấp muối', category: 'dinner', ingredients: [2023, 2079, 2080] },
  { id: 3089, name: 'Sườn hấp', category: 'dinner', ingredients: [2021, 2076, 2079] },
  { id: 3090, name: 'Đậu hũ hấp', category: 'vegetarian', ingredients: [2035, 2078, 2079] },

  // MÓN NƯỚNG (GRILLED) (10 dishes)
  { id: 3091, name: 'Thịt heo nướng', category: 'dinner', ingredients: [2021, 2076, 2080] },
  { id: 3092, name: 'Gà nướng', category: 'dinner', ingredients: [2023, 2076, 2079, 2080] },
  { id: 3093, name: 'Cá nướng', category: 'dinner', ingredients: [2027, 2076, 2079, 2080] },
  { id: 3094, name: 'Tôm nướng', category: 'dinner', ingredients: [2031, 2076, 2079] },
  { id: 3095, name: 'Mực nướng', category: 'dinner', ingredients: [2033, 2076, 2080] },
  { id: 3096, name: 'Sườn nướng BBQ', category: 'dinner', ingredients: [2021, 2076, 2095] },
  { id: 3097, name: 'Cánh gà nướng', category: 'dinner', ingredients: [2023, 2076, 2079] },
  { id: 3098, name: 'Bò nướng lá lốt', category: 'dinner', ingredients: [2022, 2076, 2078] },
  { id: 3099, name: 'Cá thu nướng', category: 'dinner', ingredients: [2030, 2076, 2079] },
  { id: 3100, name: 'Đậu hũ nướng', category: 'vegetarian', ingredients: [2035, 2076, 2080] },

  // MÓN ĂN SÁNG (BREAKFAST) (5 dishes)
  { id: 3101, name: 'Bánh mì trứng', category: 'breakfast', ingredients: [2070, 2025, 2016] },
  { id: 3102, name: 'Xôi gà', category: 'breakfast', ingredients: [2063, 2023, 2078] },
  { id: 3103, name: 'Cháo gà', category: 'breakfast', ingredients: [2061, 2023, 2079, 2078] },
  { id: 3104, name: 'Bánh cuốn', category: 'breakfast', ingredients: [2066, 2021, 2081, 2078] },
  { id: 3105, name: 'Xôi xéo', category: 'breakfast', ingredients: [2063, 2038, 2078] },
];

async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'Health',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'Kiet2004',
  });

  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('🚀 Starting comprehensive Vietnamese data generation...\n');

    // ========================================================================
    // STEP 1: Insert New Foods
    // ========================================================================
    console.log('📦 STEP 1: Inserting 95 new Vietnamese foods...');
    let foodCount = 0;
    for (const food of NEW_FOODS) {
      await client.query(
        `INSERT INTO food (id, name, name_vi, category, created_at, updated_at)
         VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
         ON CONFLICT (id) DO NOTHING`,
        [food.id, food.name, food.name_vi, food.category]
      );
      foodCount++;
    }
    console.log(`✅ Inserted ${foodCount} foods\n`);

    // ========================================================================
    // STEP 2: Insert Food Nutrients
    // ========================================================================
    console.log('🔬 STEP 2: Inserting food nutrients...');
    let nutrientCount = 0;
    for (const food of NEW_FOODS) {
      for (const [nutrientId, amount] of Object.entries(food.nutrients)) {
        await client.query(
          `INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g)
           VALUES ($1, $2, $3)
           ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = $3`,
          [food.id, parseInt(nutrientId), amount]
        );
        nutrientCount++;
      }
    }
    console.log(`✅ Inserted ${nutrientCount} nutrient entries\n`);

    // ========================================================================
    // STEP 3: Insert Food Recommendations for ALL 39 Conditions
    // ========================================================================
    console.log('💊 STEP 3: Inserting comprehensive food recommendations...');
    let recommendCount = 0;
    for (const [conditionId, recommendations] of Object.entries(COMPREHENSIVE_FOOD_RECOMMENDATIONS)) {
      // Insert avoid recommendations
      for (const foodId of recommendations.avoid) {
        await client.query(
          `INSERT INTO foodhealthcondition (food_id, health_condition_id, recommendation_type, created_at, updated_at)
           VALUES ($1, $2, 'AVOID', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
           ON CONFLICT (food_id, health_condition_id) DO UPDATE SET recommendation_type = 'AVOID'`,
          [foodId, parseInt(conditionId)]
        );
        recommendCount++;
      }
      
      // Insert recommend recommendations
      for (const foodId of recommendations.recommend) {
        await client.query(
          `INSERT INTO foodhealthcondition (food_id, health_condition_id, recommendation_type, created_at, updated_at)
           VALUES ($1, $2, 'RECOMMEND', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
           ON CONFLICT (food_id, health_condition_id) DO UPDATE SET recommendation_type = 'RECOMMEND'`,
          [foodId, parseInt(conditionId)]
        );
        recommendCount++;
      }
    }
    console.log(`✅ Inserted ${recommendCount} food recommendations for 39 conditions\n`);

    // ========================================================================
    // STEP 4: Insert Comprehensive Vietnamese Dishes
    // ========================================================================
    console.log('🍲 STEP 4: Inserting 105 Vietnamese dishes...');
    let dishCount = 0;
    for (const dish of COMPREHENSIVE_VIETNAMESE_DISHES) {
      await client.query(
        `INSERT INTO dish (id, name, name_vi, category, created_at, updated_at)
         VALUES ($1, $2, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
         ON CONFLICT (id) DO NOTHING`,
        [dish.id, dish.name, dish.category]
      );
      dishCount++;
    }
    console.log(`✅ Inserted ${dishCount} dishes\n`);

    // ========================================================================
    // STEP 5: Insert Dish Ingredients
    // ========================================================================
    console.log('🥘 STEP 5: Linking dishes to ingredients...');
    let ingredientCount = 0;
    for (const dish of COMPREHENSIVE_VIETNAMESE_DISHES) {
      for (let i = 0; i < dish.ingredients.length; i++) {
        const foodId = dish.ingredients[i];
        const quantity = i === 0 ? 100 : (i === 1 ? 80 : 30); // Main ingredient gets 100g
        await client.query(
          `INSERT INTO dishingredient (dish_id, food_id, quantity_grams)
           VALUES ($1, $2, $3)
           ON CONFLICT (dish_id, food_id) DO UPDATE SET quantity_grams = $3`,
          [dish.id, foodId, quantity]
        );
        ingredientCount++;
      }
    }
    console.log(`✅ Inserted ${ingredientCount} dish-ingredient links\n`);

    // ========================================================================
    // STEP 6: Calculate Dish Nutrients from Food Nutrients
    // ========================================================================
    console.log('⚗️  STEP 6: Calculating dish nutrients...');
    let dishNutrientCount = 0;
    
    for (const dish of COMPREHENSIVE_VIETNAMESE_DISHES) {
      // Get all ingredients and their nutrients
      const ingredientsResult = await client.query(
        `SELECT di.food_id, di.quantity_grams, fn.nutrient_id, fn.amount_per_100g
         FROM dishingredient di
         JOIN foodnutrient fn ON di.food_id = fn.food_id
         WHERE di.dish_id = $1`,
        [dish.id]
      );

      // Calculate weighted nutrient amounts
      const nutrientTotals = {};
      let totalWeight = 0;

      for (const row of ingredientsResult.rows) {
        const weight = parseFloat(row.quantity_grams);
        totalWeight += weight;
        const nutrientId = row.nutrient_id;
        const amountPer100g = parseFloat(row.amount_per_100g);
        const weightedAmount = (amountPer100g * weight) / 100;

        if (!nutrientTotals[nutrientId]) {
          nutrientTotals[nutrientId] = 0;
        }
        nutrientTotals[nutrientId] += weightedAmount;
      }

      // Insert dish nutrients (per 100g of dish)
      for (const [nutrientId, totalAmount] of Object.entries(nutrientTotals)) {
        const amountPer100g = (totalAmount / totalWeight) * 100;
        await client.query(
          `INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g)
           VALUES ($1, $2, $3)
           ON CONFLICT (dish_id, nutrient_id) DO UPDATE SET amount_per_100g = $3`,
          [dish.id, parseInt(nutrientId), amountPer100g]
        );
        dishNutrientCount++;
      }
    }
    console.log(`✅ Calculated ${dishNutrientCount} dish nutrient entries\n`);

    // ========================================================================
    // STEP 7: Verification
    // ========================================================================
    console.log('🔍 STEP 7: Verification...');
    
    const totalFoodsResult = await client.query('SELECT COUNT(*) FROM food');
    console.log(`📊 Total foods in database: ${totalFoodsResult.rows[0].count}`);

    const totalDishesResult = await client.query('SELECT COUNT(*) FROM dish');
    console.log(`📊 Total dishes in database: ${totalDishesResult.rows[0].count}`);

    const coverageResult = await client.query(`
      SELECT hc.id, hc.name, hc.name_vi,
             COUNT(DISTINCT CASE WHEN fhc.recommendation_type = 'AVOID' THEN fhc.food_id END) as avoid_count,
             COUNT(DISTINCT CASE WHEN fhc.recommendation_type = 'RECOMMEND' THEN fhc.food_id END) as recommend_count
      FROM healthcondition hc
      LEFT JOIN foodhealthcondition fhc ON hc.id = fhc.health_condition_id
      GROUP BY hc.id, hc.name, hc.name_vi
      ORDER BY hc.id
    `);

    console.log('\n📋 Coverage by Health Condition:');
    let fullCoverage = 0;
    for (const row of coverageResult.rows) {
      const status = (row.avoid_count > 0 || row.recommend_count > 0) ? '✅' : '❌';
      console.log(`${status} [${row.id}] ${row.name_vi}: ${row.avoid_count} avoid, ${row.recommend_count} recommend`);
      if (row.avoid_count > 0 || row.recommend_count > 0) fullCoverage++;
    }
    console.log(`\n🎯 Coverage: ${fullCoverage}/39 conditions (${Math.round(fullCoverage/39*100)}%)`);

    await client.query('COMMIT');
    console.log('\n✅ ALL DONE! Comprehensive Vietnamese data generated successfully! 🎉');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
