package tests
{
	import core.MediaArrangerCore;
	import core.mediaInfo.Show;

	import flexunit.framework.Assert;

	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	public class MediaArrangerCore_test
	{
		private var m_core:MediaArrangerCore;

		[Before]
		public function setUp():void
		{
			m_core =new MediaArrangerCore();
		}

		[After]
		public function tearDown():void
		{
		}

		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}

		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}

		[Test]
		public function testProcessShow_good_input_1():void
		{
			var fileName:String = "Futurama.S06E09.720p.HDTV.x264-CTU.mkv";
			var episodeInfo:Array = [".S06E09", "S06","E09"];
			var result:Show = m_core.processShow(fileName, episodeInfo);

			assertTrue(result.name=="Futurama");
			assertTrue(result.episode==9);
			assertTrue(result.season==6);

		}

		[Test]
		public function testProcessShow_good_input_2():void
		{
			var fileName:String = "family_guy_s08e21.mkv";
			var episodeInfo:Array = ["s08e21", "s08","E21"];
			var result:Show = m_core.processShow(fileName, episodeInfo);

			assertTrue(result.name=="Family Guy");
			assertTrue(result.episode==21);
			assertTrue(result.season==8);

		}

		[Test]
		public function testProcessShow_good_input_3():void
		{
			var fileName:String = "The.Big.Bang.Theory.S05E10.HDTV.XviD-ASAP.avi";
			var episodeInfo:Array = [".S05E10", "S05","E10"];
			var result:Show = m_core.processShow(fileName, episodeInfo);

			assertTrue(result.name=="The Big Bang Theory");
			assertTrue(result.episode==10);
			assertTrue(result.season==5);
		}

		[Test]
		public function testProcessShow_good_input_4():void
		{
			var fileName:String = "Family_Guy_-_S01E02.avi";
			var episodeInfo:Array = ["_S0101", "S01","E02"];
			var result:Show = m_core.processShow(fileName, episodeInfo);

			assertTrue(result.name=="Family Guy");
			assertTrue(result.season==1);
			assertTrue(result.episode==2);
		}

		[Test]
		public function testProcessShow_no_name():void
		{
			var fileName:String = "1x18 - Home Soil.avi";
			var episodeInfo:Object = m_core.extractEpisodeInfo(fileName);
			var result:Show = m_core.processShow(fileName, episodeInfo);
		}
	}
}