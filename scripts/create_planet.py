"""
어린왕자 스타일 행성 3D 모델 생성 스크립트
Blender에서 실행: blender --background --python create_planet.py

사용법:
1. Blender 설치 (brew install --cask blender)
2. 터미널에서 실행:
   /Applications/Blender.app/Contents/MacOS/Blender --background --python scripts/create_planet.py
3. assets/models/little_prince_planet.glb 파일 생성됨
"""

import bpy
import math
import random
import os

# 기존 오브젝트 모두 삭제
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# 컬렉션 생성
collection = bpy.data.collections.new("Planet")
bpy.context.scene.collection.children.link(collection)

def create_material(name, color, roughness=0.8, metallic=0.0):
    """PBR 머티리얼 생성"""
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat

# 머티리얼 정의
mat_planet = create_material("Planet", (0.85, 0.7, 0.5), roughness=0.9)  # 황토색
mat_grass = create_material("Grass", (0.3, 0.6, 0.2), roughness=0.8)  # 초록
mat_tree_trunk = create_material("TreeTrunk", (0.4, 0.25, 0.1), roughness=0.9)  # 갈색
mat_tree_leaves = create_material("TreeLeaves", (0.2, 0.5, 0.15), roughness=0.7)  # 진초록
mat_flower_red = create_material("FlowerRed", (0.9, 0.2, 0.2), roughness=0.6)  # 빨강
mat_flower_yellow = create_material("FlowerYellow", (1.0, 0.85, 0.2), roughness=0.6)  # 노랑
mat_house_wall = create_material("HouseWall", (0.95, 0.85, 0.7), roughness=0.9)  # 베이지
mat_house_roof = create_material("HouseRoof", (0.6, 0.3, 0.3), roughness=0.8)  # 적갈색
mat_lamp_pole = create_material("LampPole", (0.2, 0.2, 0.2), roughness=0.4, metallic=0.8)  # 검정
mat_lamp_light = create_material("LampLight", (1.0, 0.95, 0.7), roughness=0.3)  # 노란빛

def add_to_collection(obj):
    """오브젝트를 컬렉션에 추가"""
    collection.objects.link(obj)
    if obj.name in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.unlink(obj)

# 1. 행성 본체 (구체)
bpy.ops.mesh.primitive_uv_sphere_add(radius=1.0, segments=64, ring_count=32, location=(0, 0, 0))
planet = bpy.context.active_object
planet.name = "Planet"
planet.data.materials.append(mat_planet)
add_to_collection(planet)

# 행성 표면에 약간의 범프 추가 (스컬프팅 효과)
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.subdivide(number_cuts=2)
bpy.ops.object.mode_set(mode='OBJECT')

# 버텍스 랜덤 디스플레이스
random.seed(42)
for v in planet.data.vertices:
    noise = random.uniform(-0.02, 0.02)
    v.co = v.co * (1 + noise)

# 크레이터 추가 함수
def add_crater(location, size):
    """행성 표면에 크레이터 추가"""
    bpy.ops.mesh.primitive_uv_sphere_add(radius=size, segments=16, ring_count=8, location=location)
    crater = bpy.context.active_object
    crater.name = "Crater"

    # 크레이터용 어두운 머티리얼
    mat_crater = create_material(f"Crater_{random.randint(0,100)}", (0.6, 0.5, 0.35), roughness=0.95)
    crater.data.materials.append(mat_crater)
    add_to_collection(crater)
    return crater

# 크레이터들 추가
crater_positions = [
    ((0.7, 0.5, 0.5), 0.08),
    ((-0.6, 0.6, 0.4), 0.1),
    ((0.3, -0.8, 0.4), 0.06),
    ((-0.4, -0.5, 0.7), 0.07),
    ((0.8, -0.3, 0.4), 0.05),
]

for pos, size in crater_positions:
    # 위치를 행성 표면으로 정규화
    length = math.sqrt(pos[0]**2 + pos[1]**2 + pos[2]**2)
    normalized = tuple(p/length * 0.98 for p in pos)  # 약간 안쪽으로
    add_crater(normalized, size)

# 2. 나무 생성 함수
def create_tree(location, scale=1.0):
    """어린왕자 스타일 나무"""
    # 나무 위치를 행성 표면 방향으로 정규화
    length = math.sqrt(location[0]**2 + location[1]**2 + location[2]**2)
    surface_pos = tuple(p/length * 1.0 for p in location)

    # 방향 계산 (행성 중심에서 바깥쪽)
    direction = tuple(p/length for p in location)

    # 줄기
    bpy.ops.mesh.primitive_cylinder_add(radius=0.03*scale, depth=0.15*scale, location=surface_pos)
    trunk = bpy.context.active_object
    trunk.name = "TreeTrunk"
    trunk.data.materials.append(mat_tree_trunk)

    # 줄기 방향 설정
    trunk.rotation_euler = (
        math.acos(direction[2]),
        0,
        math.atan2(direction[1], direction[0])
    )

    # 줄기 위치 조정
    offset = tuple(d * 0.075 * scale for d in direction)
    trunk.location = tuple(s + o for s, o in zip(surface_pos, offset))
    add_to_collection(trunk)

    # 나뭇잎 (구체 3개)
    leaf_offset = tuple(d * 0.18 * scale for d in direction)
    leaf_pos = tuple(s + o for s, o in zip(surface_pos, leaf_offset))

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08*scale, location=leaf_pos)
    leaves1 = bpy.context.active_object
    leaves1.name = "TreeLeaves1"
    leaves1.data.materials.append(mat_tree_leaves)
    add_to_collection(leaves1)

    # 추가 잎
    for i, offset_mult in enumerate([(0.05, 0.03), (-0.04, 0.02)]):
        side_offset = (direction[1] * offset_mult[0], -direction[0] * offset_mult[0], offset_mult[1])
        side_pos = tuple(l + s*scale for l, s in zip(leaf_pos, side_offset))
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.05*scale, location=side_pos)
        leaves = bpy.context.active_object
        leaves.name = f"TreeLeaves{i+2}"
        leaves.data.materials.append(mat_tree_leaves)
        add_to_collection(leaves)

# 3. 꽃 생성 함수
def create_flower(location, color_mat, scale=1.0):
    """어린왕자 장미 스타일 꽃"""
    length = math.sqrt(location[0]**2 + location[1]**2 + location[2]**2)
    surface_pos = tuple(p/length * 1.0 for p in location)
    direction = tuple(p/length for p in location)

    # 줄기
    bpy.ops.mesh.primitive_cylinder_add(radius=0.01*scale, depth=0.1*scale, location=surface_pos)
    stem = bpy.context.active_object
    stem.name = "FlowerStem"
    stem.data.materials.append(mat_grass)
    stem.rotation_euler = (math.acos(direction[2]), 0, math.atan2(direction[1], direction[0]))
    offset = tuple(d * 0.05 * scale for d in direction)
    stem.location = tuple(s + o for s, o in zip(surface_pos, offset))
    add_to_collection(stem)

    # 꽃잎 (5개 원형 배치)
    flower_offset = tuple(d * 0.12 * scale for d in direction)
    flower_pos = tuple(s + o for s, o in zip(surface_pos, flower_offset))

    for i in range(5):
        angle = i * 2 * math.pi / 5
        petal_offset = (math.cos(angle) * 0.03 * scale, math.sin(angle) * 0.03 * scale, 0)
        petal_pos = tuple(f + p for f, p in zip(flower_pos, petal_offset))

        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.025*scale, location=petal_pos)
        petal = bpy.context.active_object
        petal.name = f"FlowerPetal{i}"
        petal.data.materials.append(color_mat)
        add_to_collection(petal)

    # 꽃 중심
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.015*scale, location=flower_pos)
    center = bpy.context.active_object
    center.name = "FlowerCenter"
    center.data.materials.append(mat_flower_yellow)
    add_to_collection(center)

# 4. 집 생성 함수
def create_house(location, scale=1.0):
    """작은 집"""
    length = math.sqrt(location[0]**2 + location[1]**2 + location[2]**2)
    surface_pos = tuple(p/length * 1.0 for p in location)
    direction = tuple(p/length for p in location)

    # 집 본체
    offset = tuple(d * 0.05 * scale for d in direction)
    house_pos = tuple(s + o for s, o in zip(surface_pos, offset))

    bpy.ops.mesh.primitive_cube_add(size=0.1*scale, location=house_pos)
    house = bpy.context.active_object
    house.name = "HouseBody"
    house.scale = (1, 0.8, 0.7)
    house.data.materials.append(mat_house_wall)
    house.rotation_euler = (math.acos(direction[2]), 0, math.atan2(direction[1], direction[0]))
    add_to_collection(house)

    # 지붕
    roof_offset = tuple(d * 0.1 * scale for d in direction)
    roof_pos = tuple(s + o for s, o in zip(surface_pos, roof_offset))

    bpy.ops.mesh.primitive_cone_add(radius1=0.07*scale, depth=0.06*scale, location=roof_pos)
    roof = bpy.context.active_object
    roof.name = "HouseRoof"
    roof.data.materials.append(mat_house_roof)
    roof.rotation_euler = (math.acos(direction[2]), 0, math.atan2(direction[1], direction[0]))
    add_to_collection(roof)

# 5. 가로등 생성 함수
def create_lamp(location, scale=1.0):
    """어린왕자 점등인의 가로등"""
    length = math.sqrt(location[0]**2 + location[1]**2 + location[2]**2)
    surface_pos = tuple(p/length * 1.0 for p in location)
    direction = tuple(p/length for p in location)

    # 기둥
    bpy.ops.mesh.primitive_cylinder_add(radius=0.008*scale, depth=0.12*scale, location=surface_pos)
    pole = bpy.context.active_object
    pole.name = "LampPole"
    pole.data.materials.append(mat_lamp_pole)
    pole.rotation_euler = (math.acos(direction[2]), 0, math.atan2(direction[1], direction[0]))
    offset = tuple(d * 0.06 * scale for d in direction)
    pole.location = tuple(s + o for s, o in zip(surface_pos, offset))
    add_to_collection(pole)

    # 램프
    lamp_offset = tuple(d * 0.13 * scale for d in direction)
    lamp_pos = tuple(s + o for s, o in zip(surface_pos, lamp_offset))

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.025*scale, location=lamp_pos)
    lamp = bpy.context.active_object
    lamp.name = "LampLight"
    lamp.data.materials.append(mat_lamp_light)
    add_to_collection(lamp)

# 오브젝트 배치
create_tree((0.3, 0.3, 0.9), scale=1.2)
create_tree((-0.5, 0.7, 0.5), scale=0.8)
create_flower((0.8, 0.2, 0.5), mat_flower_red, scale=1.0)
create_flower((-0.3, 0.9, 0.3), mat_flower_yellow, scale=0.8)
create_flower((0.1, -0.7, 0.7), mat_flower_red, scale=0.9)
create_house((-0.7, -0.4, 0.6), scale=1.0)
create_lamp((0.5, -0.6, 0.6), scale=1.0)
create_lamp((-0.2, 0.4, 0.9), scale=0.7)

# 풀 추가
for i in range(8):
    angle = i * math.pi / 4 + random.uniform(-0.2, 0.2)
    z = random.uniform(0.3, 0.8)
    r = math.sqrt(1 - z*z)
    x = r * math.cos(angle)
    y = r * math.sin(angle)

    bpy.ops.mesh.primitive_cone_add(radius1=0.02, depth=0.05, location=(x, y, z))
    grass = bpy.context.active_object
    grass.name = f"Grass{i}"
    grass.data.materials.append(mat_grass)

    # 풀 방향 설정
    direction = (x, y, z)
    length = math.sqrt(x*x + y*y + z*z)
    direction = tuple(d/length for d in direction)
    grass.rotation_euler = (math.acos(direction[2]), 0, math.atan2(direction[1], direction[0]))
    add_to_collection(grass)

# 라이트 추가
bpy.ops.object.light_add(type='SUN', radius=1, location=(5, 5, 5))
sun = bpy.context.active_object
sun.name = "Sun"
sun.data.energy = 3

# 카메라 추가
bpy.ops.object.camera_add(location=(3, -3, 2))
camera = bpy.context.active_object
camera.name = "Camera"
camera.rotation_euler = (math.radians(60), 0, math.radians(45))
bpy.context.scene.camera = camera

# GLB 내보내기
output_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
output_path = os.path.join(output_dir, "assets", "models", "little_prince_planet.glb")

# 디렉토리 생성
os.makedirs(os.path.dirname(output_path), exist_ok=True)

# GLB 내보내기
bpy.ops.export_scene.gltf(
    filepath=output_path,
    export_format='GLB',
    use_selection=False,
    export_apply=True,
    export_animations=False,
    export_lights=False,
    export_cameras=False,
)

print(f"GLB 파일 생성 완료: {output_path}")
