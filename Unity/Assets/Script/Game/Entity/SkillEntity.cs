using UnityEngine;
using System.Collections;
using TinyQuest.Data;

namespace TinyQuest.Entity {
	public class SkillEntity {
		private MasterSkill masterSkill;
		public string Path {
			get { return this.masterSkill.path; }
		}
		public SkillEntity(MasterSkill masterSkill) {
			this.masterSkill = masterSkill;
		}
	}
}