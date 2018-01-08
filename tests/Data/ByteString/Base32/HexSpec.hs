{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS -fno-warn-orphans #-}
module Data.ByteString.Base32.HexSpec ( spec ) where

import Control.Applicative
import Data.ByteString as BS
import Data.ByteString.Char8 as BC
import Data.ByteString.Base32.Hex
import Data.Char
import Test.Hspec
import Test.QuickCheck


instance Arbitrary ByteString where
  arbitrary = BS.pack <$> arbitrary

spec :: Spec
spec = do
  describe "encode" $ do
    it "conform rfc examples" $ do
      encode ""         `shouldBe` ""
      encode "f"        `shouldBe` "CO======"
      encode "fo"       `shouldBe` "CPNG===="
      encode "foo"      `shouldBe` "CPNMU==="
      encode "foob"     `shouldBe` "CPNMUOG="
      encode "fooba"    `shouldBe` "CPNMUOJ1"
      encode "foobar"   `shouldBe` "CPNMUOJ1E8======"

  describe "encodeNoPad" $ do
    it "conform rfc examples" $ do
      encodeNoPad ""         `shouldBe` ""
      encodeNoPad "f"        `shouldBe` "CO"
      encodeNoPad "fo"       `shouldBe` "CPNG"
      encodeNoPad "foo"      `shouldBe` "CPNMU"
      encodeNoPad "foob"     `shouldBe` "CPNMUOG"
      encodeNoPad "fooba"    `shouldBe` "CPNMUOJ1"
      encodeNoPad "foobar"   `shouldBe` "CPNMUOJ1E8"

  describe "encodeLowercase" $ do
    it "conform rfc examples" $ do
      encodeLowercase ""         `shouldBe` ""
      encodeLowercase "f"        `shouldBe` "co======"
      encodeLowercase "fo"       `shouldBe` "cpng===="
      encodeLowercase "foo"      `shouldBe` "cpnmu==="
      encodeLowercase "foob"     `shouldBe` "cpnmuog="
      encodeLowercase "fooba"    `shouldBe` "cpnmuoj1"
      encodeLowercase "foobar"   `shouldBe` "cpnmuoj1e8======"

  describe "encodeLowercaseNoPad" $ do
    it "conform rfc examples" $ do
      encodeLowercaseNoPad ""         `shouldBe` ""
      encodeLowercaseNoPad "f"        `shouldBe` "co"
      encodeLowercaseNoPad "fo"       `shouldBe` "cpng"
      encodeLowercaseNoPad "foo"      `shouldBe` "cpnmu"
      encodeLowercaseNoPad "foob"     `shouldBe` "cpnmuog"
      encodeLowercaseNoPad "fooba"    `shouldBe` "cpnmuoj1"
      encodeLowercaseNoPad "foobar"   `shouldBe` "cpnmuoj1e8"

  describe "decode" $ do
    it "conform rfc examples" $ do
      decode ""         `shouldBe` Right ""
      decode "CO======" `shouldBe` Right "f"
      decode "CPNG====" `shouldBe` Right "fo"
      decode "CPNMU===" `shouldBe` Right "foo"
      decode "CPNMUOG=" `shouldBe` Right "foob"
      decode "CPNMUOJ1" `shouldBe` Right "fooba"
      decode "CPNMUOJ1E8======" `shouldBe` Right "foobar"

    it "inverse for encode" $ property $ \bs ->
      decode (encode bs) == Right bs

    it "case insensitive" $ property $ \bs ->
      decode (BC.map toLower (encode bs)) == Right bs

    it "fail gracefully if encoded data contains non alphabet chars" $ do
      decode "#======="         `shouldBe` Left "'#' is not base32 character"
      decode "AAAAAAAA#=======" `shouldBe` Left "'#' is not base32 character"

  describe "decodeLenient" $ do
    it "conform RFC examples" $ do
      decode ""         `shouldBe` Right ""
      decode "CO======" `shouldBe` Right "f"
      decode "CPNG====" `shouldBe` Right "fo"
      decode "CPNMU===" `shouldBe` Right "foo"
      decode "CPNMUOG=" `shouldBe` Right "foob"
      decode "CPNMUOJ1" `shouldBe` Right "fooba"
      decode "CPNMUOJ1E8======" `shouldBe` Right "foobar"

    it "inverse for encode" $ property $ \bs ->
      decodeLenient (encode bs) == Right bs

    it "case insensitive" $ property $ \bs ->
      decodeLenient (BC.map toLower (encode bs)) == Right bs

    it "skip non alphabet chars" $ do
      decodeLenient "|"   `shouldBe` Right ""
      decodeLenient "C|O" `shouldBe` Right "f"
