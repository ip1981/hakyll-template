module Main
  ( main
  ) where

import Control.Applicative ((<**>))
import System.Exit (exitWith)

import qualified Options.Applicative as O
import System.FilePath ((</>))

import qualified Hakyll.Commands as Cmd
import qualified Hakyll.Core.Configuration as Conf
import qualified Hakyll.Core.Logger as Logger

import Rules (rules)

data Command
  = Build
  | Clean
  | Rebuild
  | Check Cmd.Check

parseCheck :: O.Parser Cmd.Check
parseCheck =
  O.flag
    Cmd.InternalLinks
    Cmd.All
    (O.long "all" <> O.short 'a' <> O.help "Check external links as well")

parseCommand :: O.Parser Command
parseCommand =
  O.subparser $
  O.command "build" (O.info (pure Build) (O.progDesc "Build the site")) <>
  O.command "clean" (O.info (pure Clean) (O.progDesc "Clean")) <>
  O.command "rebuild" (O.info (pure Rebuild) (O.progDesc "Clean build")) <>
  O.command
    "check"
    (O.info ((Check <$> parseCheck) <**> O.helper) (O.progDesc "Check links"))

data Options =
  Options
    { verbose :: Bool
    , outDir :: FilePath
    , srcDir :: FilePath
    , cacheDir :: FilePath
    , command :: Command
    }

parseOptions :: O.Parser Options
parseOptions =
  Options <$>
  O.switch (O.long "verbose" <> O.short 'v' <> O.help "Run in verbose mode") <*>
  O.strOption
    (O.long "output" <> O.short 'o' <> O.metavar "DIR" <> O.showDefault <>
     O.value (Conf.destinationDirectory Conf.defaultConfiguration) <>
     O.help "Output directory") <*>
  O.strOption
    (O.long "source" <> O.short 's' <> O.metavar "DIR" <> O.showDefault <>
     O.value ("." </> "src") <>
     O.help "Source directory") <*>
  O.strOption
    (O.long "cache" <> O.short 'c' <> O.metavar "DIR" <> O.showDefault <>
     O.value (Conf.storeDirectory Conf.defaultConfiguration) <>
     O.help "Cache directory") <*>
  parseCommand

main :: IO ()
main = do
  opts <-
    O.execParser
      (O.info
         (parseOptions <**> O.helper)
         (O.fullDesc <> O.header "Static site compiler"))
  let conf =
        Conf.defaultConfiguration
          { Conf.destinationDirectory = outDir opts
          , Conf.providerDirectory = srcDir opts
          , Conf.storeDirectory = cacheDir opts
          , Conf.tmpDirectory = cacheDir opts </> "tmp"
          }
  log <-
    Logger.new
      (if verbose opts
         then Logger.Debug
         else Logger.Message)
  case command opts of
    Build -> Cmd.build conf log rules >>= exitWith
    Clean -> Cmd.clean conf log
    Rebuild -> Cmd.clean conf log >> Cmd.build conf log rules >>= exitWith
    Check chk -> Cmd.check conf log chk >>= exitWith
