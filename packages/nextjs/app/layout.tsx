import type { Metadata } from "next";
import { Space_Grotesk, JetBrains_Mono } from "next/font/google";
import "./globals.css";
import { Providers } from "./providers";

const spaceGrotesk = Space_Grotesk({
  subsets: ["latin"],
  variable: "--font-space-grotesk",
});

const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  variable: "--font-jetbrains",
});

export const metadata: Metadata = {
  title: "YieldBrick | Build Real Wealth From Your Yield",
  description:
    "Stake mETH on Mantle, automatically convert yield into fractionalized Real World Assets. Principal stays 100% safe.",
  keywords: ["DeFi", "RWA", "Mantle", "mETH", "Real Estate", "Yield Farming"],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body
        className={`${spaceGrotesk.variable} ${jetbrainsMono.variable} font-sans antialiased bg-dark-900 text-white`}
      >
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
