$.getJSON('../../static/assets/animations/animations.json', function(data) {
//  $.each(data, function(val) {
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Axe/ArmorBreaker"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Axe/CycloneAxe"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Axe/SkyCleaver"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Axe/Slash"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/knife/Skill_DancingKnives"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/knife/Skill_Stab"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/knife/Skill_Backstab"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/knife/Skill_PoisonStab"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Laser/Skill_Laser01"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Bow/Shoot"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Bow/bow_bomb"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Earth/Skill_StoneSpike"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Fire/Skill_Flare"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Heal/Skill_FirstAid"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Monster/SpikeWave"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Spear/DrillMove"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Spear/Impale"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Spear/SpearAirraid"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Spear/Thrust"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Sword/Slash"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Sword/Skill_CrossSlash"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Sword/LeaveDance"));
    $('#animationSelect').append($('<option></option>').val(0).html("Battle/Skills/Sword/BlossomSword"));
//    $('#animationSelect').append($('<option></option>').val(val).html(data[val]));
//  });
});

var onPlayButtonClicked = function() {
    var id = $('#animationSelect option:selected').text();
    playAnimation(id);
}