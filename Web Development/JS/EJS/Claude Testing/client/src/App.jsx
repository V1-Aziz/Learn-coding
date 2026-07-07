import Nav from "./components/Nav";
import Hero from "./components/Hero";
import About from "./components/About";
import Skills from "./components/Skills";
import Projects from "./components/Projects";
import Contact from "./components/Contact";
import Messages from "./components/Messages";

const isMessagesPage = window.location.pathname === "/messages";

export default function App() {
  if (isMessagesPage) {
    return <Messages />;
  }

  return (
    <>
      <Nav />
      <Hero />
      <About />
      <Skills />
      <Projects />
      <Contact />
      <footer>
        <p>© {new Date().getFullYear()} Abdulaziz Alghamdi. Built with React &amp; Express.</p>
      </footer>
    </>
  );
}
