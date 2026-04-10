---
title: "ERA5 数据下载教程"
date: 2026-04-10T12:50:00+08:00
draft: false
summary: "使用 CDS API 通过 Python 下载 ECMWF ERA5 再分析数据的完整流程。"
tags:
  - ERA5
  - 气象数据
  - Python
  - 教程
---
# ERA5 数据下载教程

> 使用 CDS API 通过 Python 脚本下载 ECMWF ERA5 再分析气象数据

---

## 1. 注册与获取 API Key

### 1.1 注册账号

访问 [Copernicus Climate Data Store](https://cds.climate.copernicus.eu/) 并注册账号。

### 1.2 获取 API Key

登录后，点击右上角用户图标 → **Your profile**，页面底部可以看到：

- **Personal Access Token**（即 API Key）

### 1.3 配置本地凭证

在用户主目录下创建 `.cdsapirc` 文件：

- **Windows**: `C:\Users\<你的用户名>\.cdsapirc`
- **Linux/Mac**: `~/.cdsapirc`

文件内容：

```text
url: https://cds.climate.copernicus.eu/api
key: <你的Personal Access Token>
```

> [!IMPORTANT]
> `key` 后面直接填 Token 字符串，不要加引号。

---

## 2. 安装依赖

```bash
pip install cdsapi
```

验证安装：

```python
import cdsapi
c = cdsapi.Client()  # 如果没报错，说明配置成功
```

---

## 3. 基础用法

### 3.1 最简示例

```python
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-single-levels',     # 数据集名称
    {
        'product_type': 'reanalysis',    # 产品类型
        'variable': '2m_temperature',    # 变量
        'year': '2023',                  # 年
        'month': '01',                   # 月
        'day': '01',                     # 日
        'time': '12:00',                 # 时间 (UTC)
        'area': [40, 110, 35, 115],      # 区域 [北, 西, 南, 东]
        'format': 'netcdf',              # 输出格式
    },
    'output.nc'                          # 输出文件名
)
```

### 3.2 参数说明

| 参数 | 说明 | 示例 |
|------|------|------|
| `product_type` | 产品类型 | `'reanalysis'` |
| `variable` | 变量名（可多个） | `['2m_temperature', 'surface_pressure']` |
| `year` | 年份（可多个） | `'2023'` 或 `['2022', '2023']` |
| `month` | 月份（可多个） | `'06'` 或 `[f'{m:02d}' for m in range(1,13)]` |
| `day` | 日期（可多个） | `[f'{d:02d}' for d in range(1,32)]` |
| `time` | UTC 时间（可多个） | `'03:00'` 或 `['03:00', '04:00', '05:00']` |
| `area` | 裁剪区域 | `[北纬, 西经, 南纬, 东经]` |
| `format` | 输出格式 | `'netcdf'` 或 `'grib'` |

---

## 4. 常用变量速查

### 4.1 单层变量（single-levels）

数据集名：`reanalysis-era5-single-levels`

| API 变量名 | 含义 | 单位 |
|------------|------|------|
| `10m_u_component_of_wind` | 10m 东西风分量 | m/s |
| `10m_v_component_of_wind` | 10m 南北风分量 | m/s |
| `2m_temperature` | 2m 温度 | K |
| `surface_pressure` | 地表气压 | Pa |
| `total_precipitation` | 总降水量 | m |
| `2m_dewpoint_temperature` | 2m 露点温度 | K |
| `mean_sea_level_pressure` | 海平面气压 | Pa |
| `boundary_layer_height` | 边界层高度 | m |
| `total_cloud_cover` | 总云量 | 0~1 |

### 4.2 气压层变量（pressure-levels）

数据集名：`reanalysis-era5-pressure-levels`

| API 变量名 | 含义 | 单位 |
|------------|------|------|
| `u_component_of_wind` | 东西风 | m/s |
| `v_component_of_wind` | 南北风 | m/s |
| `temperature` | 温度 | K |
| `geopotential` | 位势 | m²/s² |
| `relative_humidity` | 相对湿度 | % |
| `specific_humidity` | 比湿 | kg/kg |

气压层需额外指定 `pressure_level` 参数：

```python
'pressure_level': ['500', '700', '850', '925', '1000']  # 单位: hPa
```

---

## 5. 实战示例

### 5.1 下载特定区域的风场数据

```python
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-single-levels',
    {
        'product_type': 'reanalysis',
        'variable': [
            '10m_u_component_of_wind',
            '10m_v_component_of_wind',
            '2m_temperature',
            'surface_pressure',
        ],
        'year': '2024',
        'month': [f'{m:02d}' for m in range(1, 13)],  # 全年
        'day': [f'{d:02d}' for d in range(1, 32)],     # 全月
        'time': ['03:00', '04:00', '05:00'],            # 仅卫星过境时段
        'area': [37, 112, 36, 113],  # 李村矿区
        'format': 'netcdf',
    },
    'era5_2024_wind.nc'
)
```

### 5.2 并行下载多年数据

```python
import cdsapi
from concurrent.futures import ThreadPoolExecutor, as_completed

def download_year(year):
    """下载单年数据"""
    output = f'era5_{year}.nc'
    try:
        c = cdsapi.Client()  # 每个线程创建独立客户端
        c.retrieve(
            'reanalysis-era5-single-levels',
            {
                'product_type': 'reanalysis',
                'variable': [
                    '10m_u_component_of_wind',
                    '10m_v_component_of_wind',
                ],
                'year': str(year),
                'month': [f'{m:02d}' for m in range(1, 13)],
                'day': [f'{d:02d}' for d in range(1, 32)],
                'time': ['03:00', '04:00', '05:00'],
                'area': [37, 112, 36, 113],
                'format': 'netcdf',
            },
            output
        )
        return f'[OK] {year}'
    except Exception as e:
        return f'[FAIL] {year}: {e}'

# 最多 4 个并发
with ThreadPoolExecutor(max_workers=4) as executor:
    futures = {executor.submit(download_year, y): y for y in range(2020, 2026)}
    for future in as_completed(futures):
        print(future.result())
```

### 5.3 下载后合并多个文件

```python
import xarray as xr

files = ['era5_2020.nc', 'era5_2021.nc', 'era5_2022.nc']
ds = xr.open_mfdataset(files, combine='by_coords')
ds.to_netcdf('era5_2020-2022_merged.nc')
ds.close()
print("合并完成")
```

### 5.4 下载气压层数据

```python
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-pressure-levels',  # 注意数据集名不同
    {
        'product_type': 'reanalysis',
        'variable': [
            'u_component_of_wind',
            'v_component_of_wind',
            'temperature',
        ],
        'pressure_level': ['850', '925'],  # 气压层 (hPa)
        'year': '2024',
        'month': '06',
        'day': '15',
        'time': '03:00',
        'area': [37, 112, 36, 113],
        'format': 'netcdf',
    },
    'era5_pressure_levels.nc'
)
```

---

## 6. 注意事项

### 6.1 请求大小限制

CDS API 对单次请求有大小限制。如果报 `403 cost limits exceeded`，需要拆分请求：

| 策略 | 说明 |
|------|------|
| **减少时间** | 只下需要的小时（如 `03:00-05:00`） |
| **拆分年份** | 按年分别提交 |
| **缩小区域** | 尽量只覆盖研究区 |

> [!TIP]
> 一般经验：**1年 × 3小时 × 小区域** 的单层数据可以一次提交。全年 24 小时的通常需要按月或按季度拆分。

### 6.2 时间说明

- ERA5 时间均为 **UTC**
- 北京时间 = UTC + 8 小时
- 例：北京时间 11:00 ≈ UTC 03:00

### 6.3 空间分辨率

- ERA5 默认分辨率：**0.25° × 0.25°**（约 25km）
- `area` 中的边界会自动对齐到最近的 0.25° 网格

### 6.4 常见错误

| 错误 | 原因 | 解决 |
|------|------|------|
| `403 cost limits exceeded` | 请求数据量太大 | 减少时间/拆分年份 |
| `ModuleNotFoundError: cdsapi` | 未安装 | `pip install cdsapi` |
| `Exception: Missing/malformed configuration` | `.cdsapirc` 配置错误 | 检查文件路径和格式 |
| `SSLError / ConnectionReset` | 网络不稳定 | 重试，或挂代理 |

---

## 7. 读取下载的数据

```python
import xarray as xr
import numpy as np

ds = xr.open_dataset('era5_2024_wind.nc', engine='netcdf4')

# 查看基本信息
print(ds)
print('变量:', list(ds.data_vars))
print('坐标:', list(ds.coords))

# 提取某时刻某位置的风速
lon, lat = 112.87, 36.09
u = ds['u10'].sel(longitude=lon, latitude=lat, method='nearest')
v = ds['v10'].sel(longitude=lon, latitude=lat, method='nearest')
wind_speed = np.sqrt(u**2 + v**2)

# 风向 (气象标准: 从北顺时针)
wind_dir = (270 - np.degrees(np.arctan2(v, u))) % 360

print(f'风速: {float(wind_speed.isel(valid_time=0)):.2f} m/s')
print(f'风向: {float(wind_dir.isel(valid_time=0)):.1f}°')

ds.close()
```

---

## 8. 参考链接

- [CDS 官网](https://cds.climate.copernicus.eu/)
- [ERA5 单层数据](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels)
- [ERA5 气压层数据](https://cds.climate.copernicus.eu/datasets/reanalysis-era5-pressure-levels)
- [CDS API 文档](https://cds.climate.copernicus.eu/how-to-api)
- [变量名查询](https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation)
