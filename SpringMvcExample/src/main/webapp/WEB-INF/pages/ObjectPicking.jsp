<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html>
<head>
		<title>object picking with three.js</title>
	</head>
	<body>
	
		<script src="http://threejs.org/build/three.min.js"></script>
		<script src="<c:url value="/resources/js/OrbitControls.js" />"></script>
		<script src="<c:url value="/resources/js/Projector.js" />"></script>
		<script src="<c:url value="/resources/js/CanvasRenderer.js" />"></script>
		
		
		<script>

		var container;
		var camera, scene, renderer;
		var plane;

		var mouse, raycaster, isShiftDown = false;

		var cubeGeometry = new THREE.BoxGeometry( 50, 50, 50 );
		var cubeMaterial = new THREE.MeshLambertMaterial( { color: 0x00ff80, overdraw: 0.5 } );

		var objects = [];

		init();
		render();

		function init() {

			container = document.createElement( 'div' );
			document.body.appendChild( container );

			var info = document.createElement( 'div' );
			info.style.position = 'absolute';
			info.style.top = '10px';
			info.style.width = '100%';
			info.style.textAlign = 'center';
			info.innerHTML = '<a href="http://threejs.org" target="_blank">three.js</a> - voxel painter<br><strong>click</strong>: add voxel, <strong>shift + click</strong>: remove voxel, <a href="javascript:save()">save .png</a>';
			container.appendChild( info );

			camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 1, 10000 );
			camera.position.set( 500, 800, 1300 );
			camera.lookAt( new THREE.Vector3() );

			scene = new THREE.Scene();

			// Grid

			var size = 500, step = 50;

			var geometry = new THREE.Geometry();

			for ( var i = - size; i <= size; i += step ) {

				geometry.vertices.push( new THREE.Vector3( - size, 0, i ) );
				geometry.vertices.push( new THREE.Vector3(   size, 0, i ) );

				geometry.vertices.push( new THREE.Vector3( i, 0, - size ) );
				geometry.vertices.push( new THREE.Vector3( i, 0,   size ) );

			}

			var material = new THREE.LineBasicMaterial( { color: 0x000000, opacity: 0.2 } );

			var line = new THREE.Line( geometry, material, THREE.LinePieces );
			scene.add( line );

			//

			raycaster = new THREE.Raycaster();
			mouse = new THREE.Vector2();

			var geometry = new THREE.PlaneBufferGeometry( 1000, 1000 );
			geometry.applyMatrix( new THREE.Matrix4().makeRotationX( - Math.PI / 2 ) );

			plane = new THREE.Mesh( geometry );
			plane.visible = false;
			scene.add( plane );

			objects.push( plane );

			var material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } );

			// Lights

			var ambientLight = new THREE.AmbientLight( 0x606060 );
			scene.add( ambientLight );

			var directionalLight = new THREE.DirectionalLight( 0xffffff );
			directionalLight.position.x = Math.random() - 0.5;
			directionalLight.position.y = Math.random() - 0.5;
			directionalLight.position.z = Math.random() - 0.5;
			directionalLight.position.normalize();
			scene.add( directionalLight );

			var directionalLight = new THREE.DirectionalLight( 0x808080 );
			directionalLight.position.x = Math.random() - 0.5;
			directionalLight.position.y = Math.random() - 0.5;
			directionalLight.position.z = Math.random() - 0.5;
			directionalLight.position.normalize();
			scene.add( directionalLight );

			renderer = new THREE.CanvasRenderer();
			renderer.setClearColor( 0xf0f0f0 );
			renderer.setPixelRatio( window.devicePixelRatio );
			renderer.setSize( window.innerWidth, window.innerHeight );
			container.appendChild(renderer.domElement);

			document.addEventListener( 'mousedown', onDocumentMouseDown, false );
			document.addEventListener( 'keydown', onDocumentKeyDown, false );
			document.addEventListener( 'keyup', onDocumentKeyUp, false );

			//

			window.addEventListener( 'resize', onWindowResize, false );

		}

		function onWindowResize() {

			camera.aspect = window.innerWidth / window.innerHeight;
			camera.updateProjectionMatrix();

			renderer.setSize( window.innerWidth, window.innerHeight );

			render();

		}

		function onDocumentMouseDown( event ) {

			event.preventDefault();

			mouse.x = ( event.clientX / renderer.domElement.width ) * 2 - 1;
			mouse.y = - ( event.clientY / renderer.domElement.height ) * 2 + 1;

			raycaster.setFromCamera( mouse, camera );

			var intersects = raycaster.intersectObjects( objects );

			if ( intersects.length > 0 ) {

				var intersect = intersects[ 0 ];

				if ( isShiftDown ) {

					if ( intersect.object != plane ) {

						scene.remove( intersect.object );

						objects.splice( objects.indexOf( intersect.object ), 1 );

					}

				} else {

					var voxel = new THREE.Mesh( cubeGeometry, cubeMaterial );
					voxel.position.copy( intersect.point ).add( intersect.face.normal );
					voxel.position.divideScalar( 50 ).floor().multiplyScalar( 50 ).addScalar( 25 );
					scene.add( voxel );

					objects.push( voxel );

				}

				render();

			}

		}

		function onDocumentKeyDown( event ) {

			switch( event.keyCode ) {

				case 16: isShiftDown = true; break;

			}

		}

		function onDocumentKeyUp( event ) {

			switch( event.keyCode ) {

				case 16: isShiftDown = false; break;

			}
		}

		function save() {

			window.open( renderer.domElement.toDataURL('image/png'), 'mywindow' );
			return false;

		}

		function render() {

			renderer.render( scene, camera );

		}

	</script>
	</body>
</html>