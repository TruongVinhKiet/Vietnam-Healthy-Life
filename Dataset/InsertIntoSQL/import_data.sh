#!/bin/bash
# Script nhập dữ liệu cho Linux/macOS

export PGPASSWORD=Kiet2004
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGDATABASE=Health

echo "========================================"
echo "NHẬP DỮ LIỆU MẪU VÀO POSTGRESQL"
echo "========================================"
echo ""

echo "[1/5] Đang nhập dữ liệu cơ bản (real_dataset_vietnam.sql)..."
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "real_dataset_vietnam.sql"
if [ $? -ne 0 ]; then
    echo "❌ LỖI khi nhập real_dataset_vietnam.sql"
    exit 1
fi
echo "✅ Hoàn thành real_dataset_vietnam.sql"
echo ""

echo "[2/5] Đang nhập dữ liệu mở rộng (extended_tables_vietnam.sql)..."
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "extended_tables_vietnam.sql"
if [ $? -ne 0 ]; then
    echo "❌ LỖI khi nhập extended_tables_vietnam.sql"
    exit 1
fi
echo "✅ Hoàn thành extended_tables_vietnam.sql"
echo ""

echo "[3/5] Đang nhập dữ liệu bổ sung (additional_data_extended.sql)..."
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "additional_data_extended.sql"
if [ $? -ne 0 ]; then
    echo "❌ LỖI khi nhập additional_data_extended.sql"
    exit 1
fi
echo "✅ Hoàn thành additional_data_extended.sql"
echo ""

echo "[4/5] Đang nhập dữ liệu dinh dưỡng món ăn (dishnutrient_data.sql)..."
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "dishnutrient_data.sql"
if [ $? -ne 0 ]; then
    echo "❌ LỖI khi nhập dishnutrient_data.sql"
    exit 1
fi
echo "✅ Hoàn thành dishnutrient_data.sql"
echo ""

echo "[5/5] Đang nhập dữ liệu dinh dưỡng đồ uống (drinknutrient_data.sql)..."
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -f "drinknutrient_data.sql"
if [ $? -ne 0 ]; then
    echo "❌ LỖI khi nhập drinknutrient_data.sql"
    exit 1
fi
echo "✅ Hoàn thành drinknutrient_data.sql"
echo ""

echo "========================================"
echo "✅ HOÀN TẤT NHẬP DỮ LIỆU!"
echo "========================================"
echo ""
echo "Thống kê:"
psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "SELECT 'nutrient' as table_name, COUNT(*) as total FROM nutrient UNION ALL SELECT 'food', COUNT(*) FROM food UNION ALL SELECT 'healthcondition', COUNT(*) FROM healthcondition UNION ALL SELECT 'drug', COUNT(*) FROM drug UNION ALL SELECT 'dish', COUNT(*) FROM dish UNION ALL SELECT 'drink', COUNT(*) FROM drink UNION ALL SELECT 'dishnutrient', COUNT(*) FROM dishnutrient UNION ALL SELECT 'drinknutrient', COUNT(*) FROM drinknutrient ORDER BY table_name;"
echo ""
