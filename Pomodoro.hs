{-
Code interacting with [gtk](https://hackage.haskell.org/package/gtk) is under 
[LGPL-2.1](https://hackage.haskell.org/package/gtk-0.15.5/src/COPYING) 
License. To the rest of program apply MIT License and below statement:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-}

import Control.Concurrent
import Graphics.UI.Gtk

pad :: Int -> String
pad num
  | num > 9   = show num
  | otherwise = "0" ++ show num

formatClock :: Int -> String
formatClock time = pad (time `div` 60) ++ ":" ++ pad (time `mod` 60)

getTime :: Bool -> Int -> Int
getTime isBreak phase
  | isBreak   = 1500
  | otherwise = if phase == 0 then 900 else 300

changePhase :: Int -> Int
changePhase 0     = 7
changePhase phase = phase - 1

changeTitle :: Window -> Bool -> IO ()
changeTitle window isBreak
  | isBreak   = opr "Focus"
  | otherwise = opr "Break"
  where opr = windowSetTitle window

timer :: Window -> Label -> Bool -> Int -> Int -> IO Bool
timer window label isBreak phase 0
  = do labelSetText label "Starting new phase..."
       timeoutAdd
         (timer window label (not isBreak) (changePhase phase) (getTime isBreak phase))
         1000
       changeTitle window isBreak
       windowPresent window
       return False
timer window label isBreak phase time
  = do labelSetText label $ formatClock time
       timeoutAdd (timer window label isBreak phase (time - 1)) 1000
       return False

main :: IO ()
main
  = do initGUI
       window <- windowNew
       label  <- labelNew (Just "Let's begin!")
       set window
         [ windowTitle := "Hello"
         , windowDefaultWidth := 175
         , windowDefaultHeight := 50]
       windowSetIconFromFile window "img/clock.png"
       containerAdd window label
       onDestroy window mainQuit
       widgetShowAll window
       timeoutAdd (timer window label True 7 0) 1000
       mainGUI

