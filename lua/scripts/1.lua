local args = {
    [1] = 1772803019.157492;
    [2] = workspace:WaitForChild("Characters", 9e9):WaitForChild("steezybackup5", 9e9):WaitForChild("Pistol .50", 9e9);
    [3] = CFrame.new(268.794128, 3279.66479, -1989.98499, 0.955141544, -0.00646764459, -0.296078831, -0, 0.999761462, -0.0218391251, 0.296149433, 0.0208594557, 0.954913855);
    [4] = {
        ["1"] = workspace:WaitForChild("Characters", 9e9):WaitForChild("cheskamaganda17", 9e9):WaitForChild("Humanoid", 9e9);
    };
    [5] = {
        [1] = {
            ["normal"] = Vector3.new(-0.5949137210845947, 0.03164765238761902, 0.8031662702560425);
            ["instance"] = workspace:WaitForChild("Characters", 9e9):WaitForChild("cheskamaganda17", 9e9):WaitForChild("Head", 9e9):WaitForChild("HeadCollision", 9e9);
            ["taggedHumanoid"] = workspace:WaitForChild("Characters", 9e9):WaitForChild("cheskamaganda17", 9e9):WaitForChild("Humanoid", 9e9);
            ["position"] = Vector3.new(273.6168212890625, 3280.0234375, -2005.380126953125);
        };
    };
}

game:GetService("ReplicatedStorage"):WaitForChild("Blaster", 9e9):WaitForChild("Remotes", 9e9):WaitForChild("Shoot", 9e9):FireServer(unpack(args))