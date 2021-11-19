	const uint MAX_PROFILES = 64;

	BotProfiles g_Profiles;

	final class BotProfile
	{
		string m_Name;
		int m_Skill;
		bool m_bUsed;
		string skin;

		BotProfile ( string name, int skill, string model = "gordon" )
		{
			m_Name = name;
			m_Skill = skill;
			m_bUsed = false;
			skin = model;
		}	
	}

	final class BotProfiles
	{
		array<BotProfile@> m_Profiles;
		array<string> modelNames;
		array<string> botNames;
		uint lastBotNameIndex;
		
		BotProfiles()
		{
			readProfiles();
		}

		void readProfiles()
		{
			string botName;
			int botSensitivity;
			string botModel;
			lastBotNameIndex = 0;

			File@ modelNamesFile = g_FileSystem.OpenFile( "scripts/plugins/BotManager/profiles/models.txt", OpenFile::READ);
			if (modelNamesFile !is null) {
				while (!modelNamesFile.EOFReached()) {
					string fileLine; modelNamesFile.ReadLine(fileLine);
					g_Game.AlertMessage( at_console, "Custom model name: " );
					g_Game.AlertMessage( at_console, fileLine );
					g_Game.AlertMessage( at_console, "\n" );
					modelNames.insertLast(fileLine);
				}
			}

			File@ botNamesFile = g_FileSystem.OpenFile( "scripts/plugins/BotManager/profiles/names.txt", OpenFile::READ);
			if (botNamesFile !is null) {
				while (!botNamesFile.EOFReached()) {
					string fileLine; botNamesFile.ReadLine(fileLine);
					g_Game.AlertMessage( at_console, "Custom bot name: " );
					g_Game.AlertMessage( at_console, fileLine );
					g_Game.AlertMessage( at_console, "\n" );
					botNames.insertLast(fileLine);
				}
			}

			for ( uint i = 1; i < MAX_PROFILES; i ++ )
			{
				File@ profileFile = g_FileSystem.OpenFile( "scripts/plugins/BotManager/profiles/" + i + ".ini", OpenFile::READ);

				
				botName = "Unnamed";
				botSensitivity = Math.RandomLong( 1, 4 );
				botModel = "freeman";
				if ( profileFile is null ) {
					if (modelNames.length() > 0) {
						g_Game.AlertMessage( at_console, "Model names length:" );
						g_Game.AlertMessage( at_console, modelNames.length() );
						botModel = modelNames[Math.RandomLong(0, modelNames.length() - 1)];
					}

					if (botNames.length() > 0) {
						g_Game.AlertMessage( at_console, "Bot names length:" );
						g_Game.AlertMessage( at_console, botNames.length() );
						botName = botNames[lastBotNameIndex];
						lastBotNameIndex += 1;

						if (lastBotNameIndex == botNames.length()) {
							lastBotNameIndex = 0;
						}
					}
				}

				while ( profileFile !is null && !profileFile.EOFReached() )
				{
					string fileLine; profileFile.ReadLine( fileLine );
					if ( fileLine[0] == "#" )
						continue;

					array<string> args = fileLine.Split( "=" );
					if ( args.length() < 2 )
						continue;
					args[0].Trim(); args[1].Trim();

					if ( args[0] == "name" )
						botName = args[1];
					
					if ( args[0] == "sensitivity" )
					{
						int sensitivity = atoi(args[1]);
						if ( sensitivity != 0 )
							botSensitivity = sensitivity;
					}

					if ( args[0] == "model" )
						botModel = args[1];
				}

				if (profileFile !is null)
					profileFile.Close();

				m_Profiles.insertLast(BotProfile(botName, botSensitivity, botModel));
			}
		}

		void resetProfiles ()
		{
			for ( uint i = 0; i < m_Profiles.length(); i ++ )
			{
				m_Profiles[i].m_bUsed = false;
			}
		}

		BotProfile@ getRandomProfile ()
		{
			array<BotProfile@> UnusedProfiles;

			for ( uint i = 0; i < m_Profiles.length(); i ++ )
			{
				if ( !m_Profiles[i].m_bUsed )
				{
					UnusedProfiles.insertLast(m_Profiles[i]);
				}
			}

			if ( UnusedProfiles.length() > 0 )
			{
				return UnusedProfiles[Math.RandomLong(0, UnusedProfiles.length()-1)];
			}

			return null;
		}
	}