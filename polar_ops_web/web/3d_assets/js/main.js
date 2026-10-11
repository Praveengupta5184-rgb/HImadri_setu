// Scene setup
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x1a1a1a);

const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.getElementById('3d-container').appendChild(renderer.domElement);

// Add lights
const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
scene.add(ambientLight);
const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(10, 20, 10);
scene.add(directionalLight);

// Create station rooms (simple cubes for demo)
const rooms = [
    { id: 1, name: "Lab 1", position: { x: -6, y: 0, z: 0 }, color: 0x4caf50, inventory: "Normal", assets: 5, personnel: 3 },
    { id: 2, name: "Lab 2", position: { x: 0, y: 0, z: 0 }, color: 0xf44336, inventory: "Critical", assets: 3, personnel: 2 },
    { id: 3, name: "Storage Room", position: { x: 6, y: 0, z: 0 }, color: 0xff9800, inventory: "Warning", assets: 10, personnel: 1 },
];

rooms.forEach(room => {
    const geometry = new THREE.BoxGeometry(4, 3, 4);
    // Wireframe overlay for futuristic look
    const edges = new THREE.EdgesGeometry(geometry);
    const line = new THREE.LineSegments(edges, new THREE.LineBasicMaterial({ color: 0xffffff }));
    
    const material = new THREE.MeshLambertMaterial({ color: room.color, transparent: true, opacity: 0.8 });
    const cube = new THREE.Mesh(geometry, material);
    
    cube.position.set(room.position.x, room.position.y, room.position.z);
    line.position.copy(cube.position);
    
    cube.userData = room; // Store room data
    scene.add(cube);
    scene.add(line);
});

// Camera position
camera.position.set(0, 10, 15);
camera.lookAt(0, 0, 0);

// Orbit controls
const controls = new THREE.OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;

// Raycaster for click detection
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();

window.addEventListener('click', onMouseClick, false);

function onMouseClick(event) {
    mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
    mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    
    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(scene.children);
    
    if (intersects.length > 0) {
        // Find the first mesh that isn't a wireframe line
        const target = intersects.find(i => i.object.type === 'Mesh');
        if (target && target.object.userData.name) {
            showPopup(target.object.userData);
        }
    } else {
        closePopup();
    }
}

function showPopup(room) {
    document.getElementById('room-name').innerText = room.name;
    document.getElementById('room-inventory').innerText = room.inventory;
    document.getElementById('room-assets').innerText = room.assets;
    document.getElementById('room-personnel').innerText = room.personnel;
    
    // Style color based on status
    const invEl = document.getElementById('room-inventory');
    invEl.style.color = room.inventory === 'Critical' ? '#ff4c4c' : (room.inventory === 'Warning' ? '#ffa726' : '#66bb6a');
    
    document.getElementById('room-popup').style.display = 'block';
}

function closePopup() {
    document.getElementById('room-popup').style.display = 'none';
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
}
animate();

// Handle window resize
window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});
