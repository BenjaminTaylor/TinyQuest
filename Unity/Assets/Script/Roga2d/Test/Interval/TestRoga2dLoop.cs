using UnityEngine;
using System.Collections.Generic;

class TestRoga2dLoop {
	
	public static void Test() {
		Test2Loop();
		TestInfiniteLoop();
	}
	
	public static void Test2Loop() {
		Roga2dNode node = new Roga2dNode();

		Roga2dAlphaInterval interval1 = new Roga2dAlphaInterval(node, 0.1f, 1.0f, 1, true);
		Roga2dWait interval2 = new Roga2dWait(1);
		Roga2dAlphaInterval interval3 = new Roga2dAlphaInterval(node, 0.7f, 0.0f, 1, true);

		List<Roga2dBaseInterval> intervals = new List<Roga2dBaseInterval>();
		intervals.Add(interval1);
		intervals.Add(interval2);
		intervals.Add(interval3);
		
		Roga2dSequence sequence = new Roga2dSequence(intervals);
		Roga2dLoop loop = new Roga2dLoop(sequence, 2);
		
		loop.Start();
		Tester.Match(node.LocalAlpha, 0.1f);
		Tester.Ok(!loop.IsDone());
		
		loop.Update();
		Tester.Match(node.LocalAlpha, 1.0f);
		Tester.Ok(!loop.IsDone());

		loop.Update();
		Tester.Match(node.LocalAlpha, 1.0f);
		Tester.Ok(!loop.IsDone());
		
		loop.Update();
		Tester.Match(node.LocalAlpha, 0.1f);
		Tester.Ok(!loop.IsDone());
		
		loop.Update();
		Tester.Match(node.LocalAlpha, 1.0f);
		Tester.Ok(!loop.IsDone());
		
		loop.Update();
		Tester.Match(node.LocalAlpha, 1.0f);
		Tester.Ok(!loop.IsDone());
			
		loop.Update();
		Tester.Match(node.LocalAlpha, 0.0f);
		Tester.Ok(loop.IsDone());
		
		node.Destroy();
	}
	
	public static void TestInfiniteLoop() {
		Roga2dNode node = new Roga2dNode();

		Roga2dAlphaInterval interval1 = new Roga2dAlphaInterval(node, 0.1f, 1.0f, 1, true);
		Roga2dWait interval2 = new Roga2dWait(1);
		Roga2dAlphaInterval interval3 = new Roga2dAlphaInterval(node, 0.7f, 0.0f, 1, true);

		List<Roga2dBaseInterval> intervals = new List<Roga2dBaseInterval>();
		intervals.Add(interval1);
		intervals.Add(interval2);
		intervals.Add(interval3);
		
		Roga2dSequence sequence = new Roga2dSequence(intervals);
		Roga2dLoop loop = new Roga2dLoop(sequence, 0);
		
		loop.Start();
		Tester.Match(node.LocalAlpha, 0.1f);
		Tester.Ok(!loop.IsDone());
           
        for (int i = 0; i < 4; i++) {
            loop.Update();
			Tester.Match(node.LocalAlpha, 1.0f);
            Tester.Ok(!loop.IsDone());

            loop.Update();
			Tester.Match(node.LocalAlpha, 1.0f);
            Tester.Ok(!loop.IsDone());

            loop.Update();
			Tester.Match(node.LocalAlpha, 0.1f);
            Tester.Ok(!loop.IsDone());
        }   
	
		node.Destroy();
	}
}