[Setting name="Move Compass"]
bool Setting_MoveCompass = false;
[Setting name="Show Compass"]
bool Setting_ShowCompass = true;
[Setting name="Compass Line Width"]
float Setting_CompassLineWidth = 2;
[Setting name="Center Line Width"]
float Setting_CenterLineWidth = 10;
[Setting name="Center Line Color"]
vec4 Setting_CenterLineColor = vec4(1, 1, 1, 1);

[Setting name="Grip Color"]
vec4 Setting_GripColor = vec4(0, 1, 0, 1);
[Setting name="Warn Color"]
vec4 Setting_WarnColor = vec4(1, 1, 0, 1);
[Setting name="Slip Color"]
vec4 Setting_SlipColor = vec4(1, 0, 0, 1);


[Setting hidden]
int Setting_CompassX = 0;
[Setting hidden]
int Setting_CompassY = 0;
[Setting hidden]
int Setting_CompassW = 300;
[Setting hidden]
int Setting_CompassH = 200;

void Main() {
}

void Render() {
    if (Setting_ShowCompass) {
        CSceneVehicleVisState@ state = VehicleState::ViewingPlayerState();
        if (state == null) return;
        vec3 vel = state.WorldVel;
        vec3 dir = state.Dir;
        vec2 velNorm = vec2(vel.x, vel.z).Normalized();
        vec2 dirNorm = vec2(dir.x, dir.z).Normalized();
        float cross = vel.x*dir.z - vel.z*dir.x;
        float sign = 0;
        if (cross != 0.0f) {
            sign = Math::Abs(cross)/cross;
        }
        float A = Math::Acos(Math::Dot(dirNorm, velNorm)) * sign;
        if (Math::IsNaN(A) || Math::IsInf(A)) {
            A = 0;
        }

        vec4 color;
        if (state.FLSlipCoef == 0 && state.FRSlipCoef == 0 && state.RLSlipCoef == 0 && state.RLSlipCoef == 0) {
            color = Setting_GripColor;
        } else if (state.FLSlipCoef != 0 && state.FRSlipCoef != 0 && state.RLSlipCoef != 0 && state.RLSlipCoef != 0) {
            color = Setting_SlipColor;
        } else {
            color = Setting_WarnColor;
        }

        nvg::BeginPath();

        nvg::MoveTo(vec2(Setting_CompassX + Setting_CompassW/2, Setting_CompassY));
        nvg::LineTo(vec2(Setting_CompassX + Setting_CompassW/2, Setting_CompassY + Setting_CompassH));
        nvg::StrokeColor(Setting_CenterLineColor);
        nvg::StrokeWidth(Setting_CenterLineWidth);
        nvg::Stroke();

        nvg::ClosePath();

        nvg::BeginPath();

        nvg::Translate(vec2(Setting_CompassX + Setting_CompassW/2, Setting_CompassY + Setting_CompassH/2));
        nvg::Rotate(A);

        nvg::MoveTo(vec2(0,-Setting_CompassH/2));
        nvg::LineTo(vec2(0, Setting_CompassH/2));
        nvg::StrokeColor(color);
        nvg::StrokeWidth(Setting_CompassLineWidth);
        nvg::Stroke();

        nvg::ClosePath();
    }

    if (!Setting_MoveCompass) return;
    UI::SetNextWindowSize(Setting_CompassW, Setting_CompassH, UI::Cond::Appearing);
    if (UI::Begin("Advanced Cam 2 Settings", Setting_MoveCompass, UI::WindowFlags::NoTitleBar)) {
        vec2 pos = UI::GetWindowPos();
        Setting_CompassX = pos.x;
        Setting_CompassY = pos.y;
        vec2 size = UI::GetWindowSize();
        Setting_CompassW = size.x;
        Setting_CompassH = size.y;
    }
    UI::End();
}