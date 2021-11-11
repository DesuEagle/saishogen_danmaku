require daslib/media
// options debugger            // uncomment for debug in VS Code
// require daslib/debug        // uncomment for debug in VS Code




struct Hero
    hitbox_radius: float
    pos: float2
    invTime: float
    speed: float
    hero_sprite_size: float2
    hero_hitbox_size: float2
    ttf: float
    ttf_current: float
    power_level: int
    vulnerable: bool
    invul_time: float2
    lives: int

struct Bullet
    pos: float2
    vel: float2
    size: float2
    alive: bool


struct Enemy
    en_type: int
    hit_points: int
    radius: float
    size: float2
    pos: float2
    vel: float2
    alive: bool
    final_y: float
    vulnerable: bool
    can_shoot: bool
    fire_rate: float
    tts: float


struct Projectile
    radius: float
    alive: bool
    p_type: int
    pos: float2
    vel: float2

struct Explosion
    size: float2
    pos: float2
    ttl: float
    e_type: int
    frame: float


var 
    waves_start = [[bool[5] false; false; false; false; false]]
    waves_end = [[bool[5] false; false; false; false; false]]
    orin_hero_png: ImageHandle
    enemies_png: ImageHandle
    projectiles_png: ImageHandle
    bg_jpg: ImageHandle
    clouds1_png: ImageHandle
    clouds2_png: ImageHandle
    orin_hero: Hero
    frame_num: float
    bullets: array<Bullet>
    cloud1_y: float
    cloud_iterator_1: float
    cloud_iterator_2: float
    bg_iterator: int
    enemies: array<Enemy>
    upgrade_number = [[int[6] 1; 2; 2; 1; 2; 10]]
    upgrade_stage: int
    enemies_to_upgrade: int
    current_wave_start: float
    wave_number: int
    enemies_shot: int
    projectiles: array<Projectile>
    explosions: array<Explosion>
    seed: int4
    wave2_tts: float
    wave2_max_tts: float
    show_started: bool
    show_phase_1: float3
    show_phase_2: float3
    final_tts: float2
    final_phase: bool
    the_end: bool


def move_hero(var s: Hero; dir: float2)
    if get_key(VK_LSHIFT)
        s.pos += dir*s.speed/2.0
    else
        s.pos += dir*s.speed

    var border_size = 10.0
    if s.pos.x < border_size + s.hero_sprite_size.x/2.0
        s.pos.x = border_size + s.hero_sprite_size.x/2.0
    if s.pos.y < border_size + s.hero_sprite_size.y/2.0
        s.pos.y = border_size + s.hero_sprite_size.y/2.0
    if s.pos.x > float(get_screen_width()) - s.hero_sprite_size.x/2.0 - border_size
        s.pos.x = float(get_screen_width()) - s.hero_sprite_size.x/2.0 - border_size
    if s.pos.y > float(get_screen_height()) - s.hero_sprite_size.y/2.0 - border_size
        s.pos.y = float(get_screen_height()) - s.hero_sprite_size.y/2.0 - border_size


def hero_render(var s: Hero)
    var sprite_pos = float2(0.0, 0.0)
    var sprite_change_speed = 3.0
    if get_key(VK_LEFT)
        sprite_pos = float2(64.0, 48.0)
        frame_num = float(int(get_time_after_start()*sprite_change_speed)%2)
    elif get_key(VK_RIGHT)
        sprite_pos = float2(64.0, 96.0)
        frame_num = float(int(get_time_after_start()*sprite_change_speed)%2)
    else 
        sprite_pos = float2(0.0, 0.0)
        frame_num = float(int(get_time_after_start()*sprite_change_speed)%4)

    draw_image_region(orin_hero_png, s.pos.x-s.hero_sprite_size.x/2.0, s.pos.y-s.hero_sprite_size.y/2.0, 
                        float4(32.0*frame_num+sprite_pos.x, 0.0+sprite_pos.y, s.hero_sprite_size.x, s.hero_sprite_size.y), 0xFFFFFFFF, s.hero_sprite_size)
    
    if s.vulnerable == false
        draw_image_region(projectiles_png, s.pos.x-30.0, s.pos.y-30.0, 
                            float4(341.0, 232.0, 30.0, 30.0), 0xFFFFFFFF, float2(60,60))
    
    if get_key(VK_LSHIFT) && the_end == false
        draw_image_region(projectiles_png, s.pos.x-s.hero_hitbox_size.x/2.0, s.pos.y-s.hero_hitbox_size.y/2.0, 
                            float4(405.0, 24.0, 62.0, 62.0), 0xFFFFFFFF, s.hero_hitbox_size)


    return(0)


def shoot(var s: Hero)
    if s.power_level == 1
        var b: Bullet
        b.size = float2(12.0, 12.0)
        b.pos = s.pos
        b.vel = float2(0.0, -500.0)
        b.alive = true
        push(bullets, b)
    if s.power_level == 2
        for iter in range(0,s.power_level)
            var x_dif = -10.0 + float(iter)*20.0
            var b: Bullet
            b.size = float2(12.0, 12.0)
            b.pos = s.pos + float2(x_dif, 0.0)
            b.vel = float2(0.0, -500.0)
            b.alive = true
            push(bullets, b)
    if s.power_level == 3
        for iter in range(0,s.power_level)
            var x_dif = -15.0 + float(iter)*15.0
            var b: Bullet
            b.size = float2(12.0, 12.0)
            b.pos = s.pos + float2(x_dif, 0.0)
            b.vel = float2(-25.0 + 25.0*float(iter), -500.0)
            b.alive = true
            push(bullets, b)
    if s.power_level == 4
        for iter in range(0,s.power_level)
            var x_dif = -25.0 + float(iter)*10.0
            var b: Bullet
            b.size = float2(12.0, 12.0)
            b.pos = s.pos + float2(x_dif, 0.0)
            b.vel = float2(-15.0 + 10.0*float(iter), -500.0)
            b.alive = true
            push(bullets, b)
    if s.power_level == 5
        for iter in range(0,s.power_level)
            var x_dif = -20.0 + float(iter)*10.0
            var b: Bullet
            b.size = float2(12.0, 12.0)
            b.pos = s.pos + float2(x_dif, 0.0)
            b.vel = float2(-12.0 + 6.0*float(iter), -500.0)
            b.alive = true
            push(bullets, b)


def bullets_update(dt: float)
    for b in bullets
        b.pos += b.vel * dt


def bullet_render(var b: Bullet)
    draw_image_region(projectiles_png, b.pos.x-b.size.x/2.0, b.pos.y-b.size.y/2.0, float4(199.0, 248.0, 12.0, 12.0), 0x00FFFFFF, b.size)
    return(0)    


def hero_reset(var s: Hero)
    s.pos.x = float(get_screen_width()) * 0.5
    s.pos.y = float(get_screen_height()) * 0.8
    s.speed = 6.0
    s.hero_sprite_size = float2(32.0, 48.0)
    s.hero_hitbox_size = float2(16.0, 16.0)
    s.ttf = 1.0
    s.ttf_current = s.ttf
    s.power_level = 1
    s.vulnerable = false
    s.invul_time = float2(5.0, 3.0)
    s.lives = 4


def spawn_enemy(var pos: float2; en_type: int)
    var en: Enemy
    en.en_type = en_type
    en.alive = true
    en.pos = pos
    en.can_shoot = false
    en.vulnerable = true
    en.fire_rate = 2.0
    en.tts = en.fire_rate

    if en_type == 0
        en.hit_points = 10
        en.radius = 26.0
        en.size = float2(32.0, 30.0)
        en.vel = float2(0, 50)
        en.final_y = 120.0     

    elif en_type == 1
        en.hit_points = 50
        en.radius = 30.0
        en.size = float2(100.0, 100.0)
        en.vel = float2(0, 75)
        en.final_y = 100.0
        en.fire_rate = 3.5
        
    elif en_type == 2
        en.hit_points = 500
        en.radius = 30.0
        en.size = float2(64.0, 64.0)
        en.vel = float2(0, 100)
        en.final_y = 100.0
        en.vulnerable = false
    
    push(enemies, en)


def play_waves(dt: float)
    //start wave
    if waves_start[wave_number] == false
        current_wave_start = get_time_after_start()
        waves_start[wave_number] = true
        if wave_number == 0
            for i in range(0,5)
                spawn_enemy(float2(get_screen_width()/2-400+200*i, -50), 0)
        elif wave_number == 2
            for i in range(0,3)
                spawn_enemy(float2(get_screen_width()/2-300+300*i, -150), 1)
        elif wave_number == 4
            spawn_enemy(float2(get_screen_width()/2, -100), 2)
    
    //wave0
    if (enemies_shot == 5 && waves_start[0] == true && waves_end[0] == false)
        waves_end[wave_number] = true
        enemies_shot = 0
        wave_number += 1
    //wave1
    if waves_start[1] == true
        if (waves_end[1] == false && get_time_after_start()-current_wave_start > 10.0)
            waves_end[1] = true
            wave_number += 1
    //wave2
    if (enemies_shot == 3 && waves_start[2] == true && waves_end[2] == false)
        waves_end[2] = true
        enemies_shot = 0
        wave_number += 1        
    //wave3
    if waves_start[3] == true
        if (waves_end[3] == false && get_time_after_start()-current_wave_start > 10.0)
            waves_end[3] = true
            wave_number += 1
    //wave4
    if waves_start[4] == true && show_started == false && get_time_after_start() - current_wave_start > 5.0
        show_started = true
    
    if wave_number < 4
        for en in enemies
            enemy_shoot(en, dt)
    
        
    

def enemies_update(dt: float)

    for en in enemies
        en.pos += en.vel * dt
        if en.pos.y >en.final_y
            en.vel.y = 0.0
            en.can_shoot = true
        if en.en_type == 2
            en.vulnerable = true


def enemy_render(var en: Enemy)
    if en.en_type == 0
        draw_image_region(enemies_png, en.pos.x-en.size.x, en.pos.y-en.size.y, float4(1.0, 740.0, en.size.x, en.size.y), 0xFFFFFFFF, 2.0*en.size)
    elif en.en_type == 1
        draw_image_region(enemies_png, en.pos.x-en.size.x, en.pos.y-en.size.y, float4(16.0, 528.0, en.size.x, en.size.y), 0xFFFFFFFF, 2.0*en.size)
    elif en.en_type == 2
        if en.hit_points > 300
            draw_image_region(enemies_png, en.pos.x-en.size.x, en.pos.y-en.size.y, float4(129.0, 390.0, en.size.x, en.size.y), 0xFFFFFFFF, 2.0*en.size)
        else
            if final_phase == false
                final_phase = true
                show_phase_1 = float3(15.0, 12.0, 0.0)
            draw_image_region(enemies_png, en.pos.x-en.size.x, en.pos.y-en.size.y, float4(129.0, 777.0, en.size.x, en.size.y), 0xFFFFFFFF, 2.0*en.size)
    return(0)  


def enemy_shoot(var en: Enemy; var dt:float)
    en.tts -= dt
    wave2_tts -= dt
    var p_type = 0
    var p_vel = float2(0.0, 0.0)
    var randomize_shot = float2(0.0, 0.0)
    if en.can_shoot == true && en.tts < 0.0 && en.en_type == 0
        for i in range(0,5)
            randomize_shot = float2(1.0, 1.0) + float2( (random_float(seed)-0.5)/2.0, (random_float(seed)-0.5)/2.0)
            p_vel = orin_hero.pos - en.pos
            p_vel = 300.0*p_vel/length(p_vel)*randomize_shot
            p_type = 0
            spawn_projectile(en.pos, p_vel, p_type)
        en.tts = en.fire_rate
        
    if en.can_shoot == true && en.tts < 0.0 &&  en.en_type == 1
                        
        p_vel = orin_hero.pos - en.pos
        p_vel = 200.0*p_vel/length(p_vel)
        p_type = 1
        spawn_projectile(en.pos, p_vel, p_type)
        en.tts = en.fire_rate

    if wave_number == 2 && wave2_tts < 0.0
        for p in range(0,3)
            for i in range(0,3)
                p_vel = 100.0*float2(2.0*(random_float(seed)-0.5), 1.0+(random_float(seed)-0.5)/2.0)
                p_type = 2
                var pos = float2(get_screen_width()/2-300+300*i, 0)
                spawn_projectile(pos, p_vel, p_type)
        wave2_tts = wave2_max_tts - random_float(seed)/2.0
    


def spawn_projectile(var pos: float2; var vel:float2; var p_type: int)
    var proj: Projectile
    proj.p_type = p_type
    proj.pos = pos
    proj.vel = vel
    proj.alive = true
    if p_type == 0
        proj.radius = 16.0
    elif p_type == 1
        proj.radius = 62.0
    elif p_type == 2
        proj.radius = 9.0
    push(projectiles, proj)


def projectiles_update(dt: float)
    for proj in projectiles
        proj.pos += proj.vel * dt
        

def projectile_render(var proj: Projectile)
    var p_size = float2(0.0, 0.0)
    if proj.p_type == 0
        p_size = float2(16.0, 16.0)
        draw_image_region(projectiles_png, proj.pos.x-p_size.x, proj.pos.y-p_size.y, float4(21.0, 54.0, p_size.x, p_size.y), 0xFFFFFFFF, 2.0*p_size)
    if proj.p_type == 1
        p_size = float2(62.0, 62.0)
        draw_image_region(projectiles_png, proj.pos.x-p_size.x, proj.pos.y-p_size.y, float4(70.0, 466.0, p_size.x, p_size.y), 0xFFFFFFFF, 2.0*p_size)
    if proj.p_type == 2
        p_size = float2(20.0, 20.0)
        draw_image_region(projectiles_png, proj.pos.x-p_size.x, proj.pos.y-p_size.y, float4(474.0, 237.0, p_size.x, p_size.y), 0xFFFFFFFF, p_size)


def upgrade_hero(var level: int; var s: Hero)
    if level == 1
        s.power_level += 1
    if level == 2
        s.ttf -= 0.3
    if level == 3
        s.power_level += 1
    if level == 4
        s.power_level += 1
    if level == 5
        s.power_level += 1
        s.ttf -= 0.2


def create_explosion(var pos: float2; var e_type: int)
    var expl: Explosion
    expl.size = float2(12,13)
    expl.pos = pos
    expl.ttl = 0.1
    expl.e_type = e_type
    expl.frame = 0.0
    push(explosions, expl)


def expl_render(var expl: Explosion)
    if expl.e_type == 0
        draw_image_region(projectiles_png, expl.pos.x-expl.size.x, expl.pos.y-expl.size.y-20.0, float4(406.0+expl.frame*16.0, 8.0, expl.size.x, expl.size.y), 0xFFFFFFFF, 2.0*expl.size)
        expl.frame += 1.0
    if expl.e_type == 1
        draw_image_region(projectiles_png, expl.pos.x-expl.size.x-20.0, expl.pos.y-expl.size.y-12.0, float4(342.0+expl.frame*16.0, 8.0, expl.size.x, expl.size.y), 0xFFFFFFFF, 6.0*expl.size)
        expl.frame += 1.0


def final_show(dt: float)
    if enemies_shot == 1
        the_end = true
    var pos: float2
    var p_vel: float2
    var p_type: int
    var randomize_shot = float2(0.0, 0.0)

    wave2_tts -= dt
    if wave2_tts < 0.0
        for p in range(0,2)
            for i in range(0,9)
                p_vel = 75.0*float2(2.0*(random_float(seed)-0.5), 1.0+(random_float(seed)-0.5)/2.0)
                p_type = 2
                pos = float2(get_screen_width()/2-448+112*i, 0)
                spawn_projectile(pos, p_vel, p_type)
        wave2_tts = wave2_max_tts + random_float(seed)/2.0  

    if final_phase == false
        show_phase_1.x -= dt
        if show_phase_1.x < 0.0 && show_phase_1.z == 0.0
            show_phase_1.x = show_phase_1.y
            show_phase_1.z = 1.0
            for i in range (0, 16)
                pos = float2(5, 5+i*32)
                p_vel = float2(115, 0)
                p_type = 0
                spawn_projectile(pos, p_vel, p_type)
        if show_phase_1.x < 0.0 && show_phase_1.z == 1.0
            show_phase_1.x = show_phase_1.y
            show_phase_1.z = 2.0
            for i in range (0, 24)
                pos = float2(5+i*32, 5)
                p_vel = float2(0, 115)
                p_type = 0
                spawn_projectile(pos, p_vel, p_type)
        if show_phase_1.x < 0.0 && show_phase_1.z == 2.0
            show_phase_1.x = show_phase_1.y
            show_phase_1.z = 3.0
            for i in range (0, 16)
                pos = float2(get_screen_width()-5, get_screen_height()-5-i*32)
                p_vel = float2(-115, 0)
                p_type = 0
                spawn_projectile(pos, p_vel, p_type)
        if show_phase_1.x < 0.0 && show_phase_1.z == 3.0
            show_phase_1.x = show_phase_1.y
            show_phase_1.z = 0.0
            for i in range (0, 24)
                pos = float2(get_screen_width()-5-i*32, get_screen_height()-5)
                p_vel = float2(0, -115)
                p_type = 0
                spawn_projectile(pos, p_vel, p_type)

    if final_phase == true
        show_phase_1.x -= dt
        show_phase_2.x -= dt
        final_tts.x -= dt
        if show_phase_2.x < 0.0 && show_phase_2.z == 0.0
            show_phase_2.x = show_phase_2.y
            show_phase_2.z = 1.0
            for i in range (0,3)
                for j in range(0,3)
                    pos = float2(get_screen_width()/5+32*i, get_screen_height()/5+j*32)
                    p_vel = float2(random_float(seed)-0.5, random_float(seed)-0.3)
                    p_vel = 50.0*p_vel/length(p_vel)
                    p_type = 0
                    spawn_projectile(pos, p_vel, p_type)
        if show_phase_2.x < 0.0 && show_phase_2.z == 1.0
            show_phase_2.x = show_phase_2.y
            show_phase_2.z = 0.0
            for i in range (0,3)
                for j in range(0,3)
                    pos = float2(4*get_screen_width()/5-32*i, get_screen_height()/5+j*32)
                    p_vel = float2(random_float(seed)-0.5, random_float(seed)-0.3)
                    p_vel = 50.0*p_vel/length(p_vel)
                    p_type = 0
                    spawn_projectile(pos, p_vel, p_type)
        
        if show_phase_1.x < 0.0 && show_phase_1.z == 0.0
            show_phase_1.x = show_phase_1.y
            for i in range (0,5)
                pos = float2(get_screen_width()/2-248+124*i, 40)
                p_vel = float2(-42 +21*i, 100)
                p_type = 1
                spawn_projectile(pos, p_vel, p_type)
        
        if final_tts.x < 0.0
            final_tts.x = final_tts.y
            for i in range(0,6)
                pos = float2(get_screen_width()/2, 100)
                randomize_shot = 150.0 * float2( (random_float(seed)-0.5)/2.0, (random_float(seed)-0.5)/2.0)
                p_vel = orin_hero.pos - pos
                p_vel = 200.0*p_vel/length(p_vel) + randomize_shot
                p_type = 0
                spawn_projectile(pos, p_vel, p_type)



// 'initialize' runs once when game starts and every hot-reload
[export]
def initialize
    set_window_title("Saishogen Danmaku")
    set_resolution(1024,768)
    bg_jpg <- create_managed_image("sprites/background.jpg")
    clouds1_png <- create_managed_image("sprites/clouds1.png")
    clouds2_png <- create_managed_image("sprites/clouds2.png")
    orin_hero_png <- create_managed_image("sprites/orin.png")
    projectiles_png <- create_managed_image("sprites/projectiles.png")
    enemies_png <- create_managed_image("sprites/enemies.png")
    reset_game()
    return


def reset_game()
    the_end = false
    randomize_seed(seed)
    cloud1_y = -2304.0
    cloud_iterator_1 = 0.0
    cloud_iterator_2 = 0.0
    bg_iterator = 0
    upgrade_stage = 0
    enemies_to_upgrade = upgrade_number[upgrade_stage]
    wave_number = 0
    enemies_shot = 0
    wave2_max_tts = 2.0
    wave2_tts = wave2_max_tts
    show_started = false
    show_phase_1 = float3(2.0, 4.5, 0.0)
    show_phase_2 = float3(5.0, 2.5, 0.0)
    final_tts = float2(3.0, 5.0)
    final_phase = false
    hero_reset(orin_hero)
    clear(enemies)
    clear(projectiles)
    clear(bullets)
    clear(explosions)
    waves_start = [[bool[5] false; false; false; false; false]]
    waves_end = [[bool[5] false; false; false; false; false]]
    upgrade_number = [[int[6] 1; 2; 2; 1; 2; 10]]
    


// this function is called to update game data,
// dt - time elapsed since the previous update (in seconds)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

    if get_key(VK_R)
        reset_game()

    if the_end == true
        clear(projectiles)
        clear(bullets)
        orin_hero.invul_time.x = 60.0
    
    if orin_hero.invul_time.x >= 0.0
        orin_hero.invul_time.x -= dt
    elif orin_hero.invul_time.x < 0.0
        orin_hero.vulnerable = true

    //final_show(dt)
    
    if show_started == false && orin_hero.lives > 0 && the_end == false
        play_waves(dt)
    elif show_started == true && orin_hero.lives > 0 && the_end == false
        final_show(dt)

    enemies_update(dt)
    bullets_update(dt)
    projectiles_update(dt)

    for b in bullets
        for en in enemies
            if length(en.pos - b.pos) < en.radius + b.size.x
                if en.vulnerable == true
                    en.hit_points -= 1
                b.alive = false
    
    for p in projectiles
        if length(orin_hero.pos - p.pos) < orin_hero.hero_hitbox_size.x/2.0 + p.radius - 2.0
            if orin_hero.vulnerable == true && orin_hero.lives > 0
                orin_hero.vulnerable = false
                orin_hero.invul_time.x = orin_hero.invul_time.y
                orin_hero.lives -= 1

    var idx = 0
    idx = length(explosions) - 1
    while idx >= 0
        explosions[idx].ttl -= dt
        if explosions[idx].frame >= 4.0
            erase(explosions, idx)
        idx--

    idx = length(bullets) - 1
    while idx >= 0
        if bullets[idx].pos.y < 0.0 || bullets[idx].pos.x < 0.0 || bullets[idx].pos.x > float(get_screen_width()) || bullets[idx].alive == false
            create_explosion(bullets[idx].pos, 0)
            erase(bullets, idx)
        idx--
    
    idx = 0
    idx = length(projectiles) - 1
    while idx >= 0
        if projectiles[idx].pos.y < -50.0 || projectiles[idx].pos.x < -50.0 || projectiles[idx].pos.x > float(get_screen_width())+50.0 || projectiles[idx].pos.y > float(get_screen_height())+50.0
            erase(projectiles, idx)
        idx--

    idx = 0
    idx = length(enemies) - 1
    while idx >= 0
        if enemies[idx].alive == false || enemies[idx].hit_points < 1 
            //if enemies[idx].en_type < 2
            create_explosion(enemies[idx].pos, 1)
            erase(enemies, idx)
            enemies_shot += 1
            enemies_to_upgrade -= 1
            if enemies_to_upgrade == 0
                upgrade_stage += 1
                enemies_to_upgrade = upgrade_number[upgrade_stage]
                upgrade_hero(upgrade_stage, orin_hero)
        idx--

    if orin_hero.lives > 0 && the_end == false
        if get_key(VK_LEFT) && !(get_key(VK_UP) || get_key(VK_DOWN) || get_key(VK_RIGHT))
            move_hero(orin_hero, float2(-1.0, 0.0))
        if get_key(VK_RIGHT) && !(get_key(VK_UP) || get_key(VK_DOWN) || get_key(VK_LEFT))
            move_hero(orin_hero, float2(1.0, 0.0))
        if get_key(VK_UP) && !(get_key(VK_LEFT) || get_key(VK_RIGHT) || get_key(VK_DOWN))
            move_hero(orin_hero, float2(0.0, -1.0))
        if get_key(VK_DOWN) && !(get_key(VK_LEFT) || get_key(VK_RIGHT) || get_key(VK_UP))
            move_hero(orin_hero, float2(0.0, 1.0))
        if get_key(VK_LEFT) && get_key(VK_UP)
            move_hero(orin_hero, float2(-1.0/sqrt(2.0), -1.0/sqrt(2.0)))
        if get_key(VK_UP) && get_key(VK_RIGHT)
            move_hero(orin_hero, float2(1.0/sqrt(2.0), -1.0/sqrt(2.0)))
        if get_key(VK_RIGHT) && get_key(VK_DOWN)
            move_hero(orin_hero, float2(1.0/sqrt(2.0), 1.0/sqrt(2.0)))
        if get_key(VK_DOWN) && get_key(VK_LEFT)
            move_hero(orin_hero, float2(-1.0/sqrt(2.0), 1.0/sqrt(2.0)))

    orin_hero.ttf_current -= dt
    if orin_hero.ttf_current < 0.0 && orin_hero.lives > 0 && the_end == false
        shoot(orin_hero)
        orin_hero.ttf_current = orin_hero.ttf

    return

// this function will be called every frame after 'act',
// you can draw anything in this function
[export]
def draw()

    if wave_number == 1 || wave_number == 3
        bg_iterator += 1
    draw_image(bg_jpg, 0, -2063 + get_screen_height()+bg_iterator)
    enable_alpha_blend()
    
    if cloud1_y+cloud_iterator_1*2.0 > 768.0
        cloud_iterator_1 = 0.0
    draw_image_region(clouds1_png, 0.0, cloud1_y+cloud_iterator_1*2.0, float4(0.0, 0.0, 256.0, 640.0), 0xFFFFFFFF, float2(1024.0, 3072.0))
    draw_image_region(clouds1_png, 0.0, -3072.0+cloud1_y+cloud_iterator_1*2.0, float4(0.0, 0.0, 256.0, 640.0), 0xFFFFFFFF, float2(1024.0, 3072.0))
    cloud_iterator_1 += 1.0

    if cloud1_y+cloud_iterator_2*4.0 > 768.0
        cloud_iterator_2 = 0.0
    draw_image_region(clouds1_png, 0.0, cloud1_y+cloud_iterator_2*4.0, float4(0.0, 0.0, 256.0, 640.0), 0xFFFFFFFF, float2(1024.0, 3072.0))
    draw_image_region(clouds1_png, 0.0, -3072.0+cloud1_y+cloud_iterator_2*4.0, float4(0.0, 0.0, 256.0, 640.0), 0xFFFFFFFF, float2(1024.0, 3072.0))
    cloud_iterator_2 += 1.0
   
    if orin_hero.lives > 0
        hero_render(orin_hero)
    disable_alpha_blend()

    enable_alpha_blend()
    for en in enemies
        enemy_render(en)

    for proj in projectiles
        projectile_render(proj)
    
    for expl in explosions
        expl_render(expl)
    disable_alpha_blend()

    for b in bullets
        bullet_render(b)
    
    set_font_name("fonts/EBGaramond-ExtraBold.ttf")
    if orin_hero.lives > 0 &&  the_end == false
        set_font_size(30)
        text_out(50, 660, "Lives: {orin_hero.lives}", 0xFF000000)
        if upgrade_stage < 5
            text_out(50, 690, "Power level: {upgrade_stage}", 0xFF000000)
            text_out(50, 720, "Enemies to upgrade: {enemies_to_upgrade}", 0xFF000000)
        else 
            text_out(50, 690, "Max power level", 0xFF000000)
    
    if orin_hero.lives == 0
        set_font_name("fonts/EBGaramond-Regular.ttf")
        set_font_size(100)
        text_out(275, 250, "YOU DIED", 0xFFFF0000)
        set_font_size(50)
        text_out(325, 375, "Press R to git gud", 0xFFFF0000)

    if the_end == true
        set_font_name("fonts/EBGaramond-Regular.ttf")
        set_font_size(100)
        text_out(275, 250, "YOU WON", 0xFFFF0000)
        set_font_size(50)
        text_out(225, 375, "Play Touhou Project to git gud", 0xFFFF0000)
        text_out(340, 450, "Press R to try again", 0xFFFF0000)

    return
