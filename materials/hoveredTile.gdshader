shader_type canvas_item;

uniform vec2 globalMousePos; // The global mouse position
uniform vec2 tileSize = vec2(16,16); // The size of each tile

varying flat vec2 vertexPos[2];

void vertex() {
    vertexPos[0] = (MODEL_MATRIX * vec4(VERTEX, 0, 1)).xy;
}

void fragment() {
    // Get the tile position based on the size of each tile
    vec2 tilePos = floor(vertexPos[0] / tileSize);
    // Get the mouse position in tile coordinates
    vec2 mouseTilePos = floor(globalMousePos / tileSize) + vec2(-1,-1);

    // Compare if the current tile is the one closest to the mouse
    // Invert the logic to highlight the hovered tile instead of others
    float highlight = 1.0 - step(0.5, distance(tilePos, mouseTilePos));

    // Highlight the tile where the mouse is hovering
    COLOR.rgb = mix(COLOR.rgb, vec3(1.0, 0.0, 0.0), highlight);
    COLOR.a = .7;
}
